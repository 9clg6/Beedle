import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/engagement_message.entity.dart';
import 'package:beedle/domain/entities/notification_record.entity.dart';
import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:beedle/domain/enum/notification_type.enum.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/domain/repositories/notification.repository.dart';
import 'package:beedle/domain/services/daily_lesson.service.dart';
import 'package:beedle/domain/services/engagement_scheduler.service.dart';
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
    required EngagementSchedulerService engagementScheduler,
    required DailyLessonService dailyLessonService,
  }) : _cardRepository = cardRepository,
       _notificationRecordRepository = notificationRecordRepository,
       _notificationEngine = localNotificationEngine,
       _appConfig = appConfig,
       _engagementScheduler = engagementScheduler,
       _dailyLessonService = dailyLessonService;

  final CardRepository _cardRepository;
  final NotificationRecordRepository _notificationRecordRepository;
  final LocalNotificationEngine _notificationEngine;
  final AppConfig _appConfig;
  final EngagementSchedulerService _engagementScheduler;
  final DailyLessonService _dailyLessonService;
  final Log _log = Log.named('NotificationScheduler');
  final Uuid _uuid = const Uuid();

  static const List<int> _teaserSlotsHour = <int>[12, 18];
  static const int _teaserIdBase = 1000;
  static const int _captureReminderId = 9999;
  static const int _dailyLessonId = 7777;

  /// Replanifie les push-teasers pour le jour courant.
  ///
  /// Stratégie CalmSurface Voice (priorité) :
  /// 1. **Engagement pool** — pioche dans les messages `short` pré-générés
  ///    par le LLM à la digestion (Beedle's Voice). Name-dropping auteur +
  ///    spécificité garantis.
  /// 2. **Fallback teaserHook** — si le pool est vide (anciennes cards
  ///    pré-feature), on retombe sur `card.teaserHook` comme avant.
  Future<void> scheduleTeasersForToday({
    required UserPreferencesEntity prefs,
    required SubscriptionSnapshotEntity subscription,
  }) async {
    if (prefs.voiceZenMode || !prefs.voicePushEnabled) {
      _log.info('Voice push disabled (zen=${prefs.voiceZenMode}).');
      for (int i = 0; i < 2; i++) {
        await _notificationEngine.cancel(_teaserIdBase + i);
      }
      return;
    }
    final int allowedCount = _resolveTeaserAllowed(prefs, subscription);
    if (allowedCount == 0) {
      _log.info('Teasers disabled (0/day).');
      return;
    }

    // Annuler les précédents teasers de la journée (slots 0 et 1).
    for (int i = 0; i < 2; i++) {
      await _notificationEngine.cancel(_teaserIdBase + i);
    }

    final List<EngagementMessageEntity> engagementPicks =
        await _engagementScheduler.nextPushCandidates(limit: allowedCount);

    if (engagementPicks.isNotEmpty) {
      await _scheduleEngagementPushes(engagementPicks);
      return;
    }

    // ── Fallback legacy ────────────────────────────────────────────
    final List<CardEntity> all = await _cardRepository.getAll();
    final List<CardEntity> candidates = all.where((CardEntity c) {
      if (!c.isGenerated) return false;
      final DateTime? v = c.viewedAt;
      return v == null || DateTime.now().difference(v).inDays >= 7;
    }).toList();

    if (candidates.isEmpty) {
      _log.info('No card candidates for teaser.');
      return;
    }

    candidates.sort((CardEntity a, CardEntity b) {
      final int aScore = _score(a, prefs);
      final int bScore = _score(b, prefs);
      return bScore.compareTo(aScore);
    });

    final List<int> slots = _teaserSlotsHour.take(allowedCount).toList();
    for (int i = 0; i < slots.length && i < candidates.length; i++) {
      final CardEntity card = candidates[i];
      final DateTime at = _resolveNextSlot(slots[i]);
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
      await _notificationRecordRepository.persist(
        NotificationRecordEntity(
          uuid: _uuid.v4(),
          type: NotificationType.teaser,
          scheduledAt: at,
          cardUuid: card.uuid,
          content: card.teaserHook,
        ),
      );
      _log.info('Scheduled teaser (legacy) "${card.teaserHook}" at $at');
    }
  }

  Future<void> _scheduleEngagementPushes(
    List<EngagementMessageEntity> picks,
  ) async {
    final List<int> slots = _teaserSlotsHour.take(picks.length).toList();
    for (int i = 0; i < slots.length; i++) {
      final EngagementMessageEntity msg = picks[i];
      final DateTime at = _resolveNextSlot(slots[i]);
      if (at.isBefore(DateTime.now().add(const Duration(minutes: 10)))) {
        continue;
      }

      await _notificationEngine.scheduleAt(
        id: _teaserIdBase + i,
        at: at,
        title: _appConfig.appName,
        body: msg.content,
        payload: 'beedle://card/${msg.cardUuid}',
      );
      await _engagementScheduler.markScheduled(msg.uuid, at);
      await _notificationRecordRepository.persist(
        NotificationRecordEntity(
          uuid: _uuid.v4(),
          type: NotificationType.teaser,
          scheduledAt: at,
          cardUuid: msg.cardUuid,
          content: msg.content,
        ),
      );
      _log.info('Scheduled engagement push "${msg.content}" at $at');
    }
  }

  /// Planifie la push "Leçon du jour" pour le prochain créneau
  /// [UserPreferencesEntity.dailyLessonHour].
  ///
  /// Respecte :
  /// - `voiceZenMode` = kill-switch
  /// - `dailyLessonPushEnabled` = opt-in explicite
  /// - Pas de push entre 22h et 8h (clamp si hour < 6 ou > 22)
  Future<void> scheduleDailyLesson({
    required UserPreferencesEntity prefs,
  }) async {
    await _notificationEngine.cancel(_dailyLessonId);
    if (prefs.voiceZenMode || !prefs.dailyLessonPushEnabled) {
      _log.info('Daily lesson push disabled.');
      return;
    }

    final CardEntity? card = await _dailyLessonService.pickTodayLesson();
    if (card == null) {
      _log.info('No daily lesson candidate.');
      return;
    }

    final int hour = prefs.dailyLessonHour.clamp(6, 22);
    final DateTime at = _resolveNextSlot(hour);
    if (at.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
      _log.info('Daily lesson slot already passed, skipping today.');
      return;
    }

    await _notificationEngine.scheduleAt(
      id: _dailyLessonId,
      at: at,
      title: _appConfig.appName,
      body: "Aujourd'hui : ${card.title}",
      payload: 'beedle://lesson',
    );
    await _notificationRecordRepository.persist(
      NotificationRecordEntity(
        uuid: _uuid.v4(),
        type: NotificationType.teaser,
        scheduledAt: at,
        cardUuid: card.uuid,
        content: card.title,
      ),
    );
    _log.info('Scheduled daily lesson "${card.title}" at $at');
  }

  /// Planifie la notif capture daily (FR-011) à l'horaire choisi.
  Future<void> scheduleCaptureReminder({
    required UserPreferencesEntity prefs,
    required String localizedBody,
  }) async {
    final DateTime at = _resolveNextSlot(prefs.captureReminderHour);

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

  int _resolveTeaserAllowed(
    UserPreferencesEntity prefs,
    SubscriptionSnapshotEntity sub,
  ) {
    // Voice quota prend précédence sur le vieux teaserCountPerDay.
    final int voiceQuota = prefs.voicePushQuotaPerDay.clamp(0, 3);
    final int freeCap = _appConfig.freemiumTeasersPerDay;
    return sub.isPro ? voiceQuota : voiceQuota.clamp(0, freeCap);
  }

  int _score(CardEntity card, UserPreferencesEntity prefs) {
    int score = 0;
    for (final String tag in card.tags) {
      if (prefs.contentCategories.any(
        (ContentCategory c) => c.name == tag.toLowerCase(),
      )) {
        score += 2;
      }
    }
    if (card.viewedAt == null) score += 3;
    return score;
  }

  DateTime _resolveNextSlot(int hour) {
    final DateTime now = DateTime.now();
    DateTime candidate = DateTime(now.year, now.month, now.day, hour);
    if (candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
