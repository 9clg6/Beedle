import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/notification_record.entity.dart';
import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:beedle/domain/enum/notification_type.enum.dart';
import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/domain/repositories/notification.repository.dart';
import 'package:beedle/foundation/config/app_config.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:uuid/uuid.dart';

/// Interface du moteur de notifications locales OS (wrap flutter_local_notifications).
abstract interface class LocalNotificationEngine {
  Future<bool> requestPermission();

  Future<void> scheduleAt({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  });

  Future<void> cancel(int id);

  Future<void> cancelAll();
}

/// Service métier qui décide **quand** et **quoi** envoyer comme push.
///
/// Respecte :
/// - P1 / FR-010 : push-teaser ≤ 2/jour, exclusion 22h-8h, espacement ≥ 6 h.
/// - Freemium Option B : 1/jour max en tier free.
/// - P1 / FR-011 : push-capture daily fixe, skip si import récent.
final class NotificationSchedulerService {
  NotificationSchedulerService({
    required CardRepository cardRepository,
    required NotificationRecordRepository notificationRecordRepository,
    required LocalNotificationEngine localNotificationEngine,
    required AppConfig appConfig,
  })  : _cardRepository = cardRepository,
        _notificationRecordRepository = notificationRecordRepository,
        _notificationEngine = localNotificationEngine,
        _appConfig = appConfig;

  final CardRepository _cardRepository;
  final NotificationRecordRepository _notificationRecordRepository;
  final LocalNotificationEngine _notificationEngine;
  final AppConfig _appConfig;
  final Log _log = Log.named('NotificationScheduler');
  final Uuid _uuid = const Uuid();

  static const List<int> _teaserSlotsHour = <int>[12, 18];
  static const int _teaserIdBase = 1000;
  static const int _captureReminderId = 9999;

  /// Replanifie les push-teasers pour le jour courant.
  Future<void> scheduleTeasersForToday({
    required UserPreferencesEntity prefs,
    required SubscriptionSnapshotEntity subscription,
  }) async {
    final allowedCount = _resolveTeaserAllowed(prefs, subscription);
    if (allowedCount == 0) {
      _log.info('Teasers disabled (0/day).');
      return;
    }

    // Annuler les précédents teasers de la journée.
    for (var i = 0; i < 2; i++) {
      await _notificationEngine.cancel(_teaserIdBase + i);
    }

    // Filtre candidats : non vus depuis > 7 j, priorité tag match.
    final all = await _cardRepository.getAll();
    final candidates = all.where((c) {
      if (!c.isGenerated) return false;
      final v = c.viewedAt;
      return v == null || DateTime.now().difference(v).inDays >= 7;
    }).toList();

    if (candidates.isEmpty) {
      _log.info('No card candidates for teaser.');
      return;
    }

    candidates.sort((a, b) {
      final aScore = _score(a, prefs);
      final bScore = _score(b, prefs);
      return bScore.compareTo(aScore);
    });

    final slots = _teaserSlotsHour.take(allowedCount).toList();
    for (var i = 0; i < slots.length && i < candidates.length; i++) {
      final card = candidates[i];
      final at = _resolveNextSlot(slots[i]);
      if (at.isBefore(DateTime.now().add(const Duration(minutes: 10)))) {
        continue;
      }

      await _notificationEngine.scheduleAt(
        id: _teaserIdBase + i,
        at: at,
        title: _appConfig.appName,
        body: card.teaserHook,
        payload: 'beedle://card/${card.uuid}',
      );
      await _notificationRecordRepository.persist(NotificationRecordEntity(
        uuid: _uuid.v4(),
        type: NotificationType.teaser,
        scheduledAt: at,
        cardUuid: card.uuid,
        content: card.teaserHook,
      ),);
      _log.info('Scheduled teaser "${card.teaserHook}" at $at');
    }
  }

  /// Planifie la notif capture daily (FR-011) à l'horaire choisi.
  Future<void> scheduleCaptureReminder({required UserPreferencesEntity prefs, required String localizedBody}) async {
    final at = _resolveNextSlot(prefs.captureReminderHour);

    await _notificationEngine.cancel(_captureReminderId);
    await _notificationEngine.scheduleAt(
      id: _captureReminderId,
      at: at,
      title: _appConfig.appName,
      body: localizedBody,
      payload: 'beedle://import',
    );

    await _notificationRecordRepository.persist(
      NotificationRecordEntity(
        uuid: _uuid.v4(),
        type: NotificationType.capture,
        scheduledAt: at,
        content: localizedBody,
      ),
    );
    _log.info('Scheduled capture reminder at $at');
  }

  int _resolveTeaserAllowed(UserPreferencesEntity prefs, SubscriptionSnapshotEntity sub) {
    final freeCap = _appConfig.freemiumTeasersPerDay;
    return sub.isPro ? prefs.teaserCountPerDay : prefs.teaserCountPerDay.clamp(0, freeCap);
  }

  int _score(CardEntity card, UserPreferencesEntity prefs) {
    var score = 0;
    for (final String tag in card.tags) {
      if (prefs.contentCategories.any((ContentCategory c) => c.name == tag.toLowerCase())) {
        score += 2;
      }
    }
    if (card.viewedAt == null) score += 3;
    return score;
  }

  DateTime _resolveNextSlot(int hour) {
    final now = DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, hour);
    if (candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
