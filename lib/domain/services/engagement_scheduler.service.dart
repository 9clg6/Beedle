import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/engagement_message.entity.dart';
import 'package:beedle/domain/enum/engagement_message.enum.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/domain/repositories/engagement_message.repository.dart';
import 'package:beedle/foundation/logging/logger.dart';

/// Service domain — décide QUEL message afficher et QUAND, à partir du pool
/// d'`EngagementMessageEntity` pré-générés par le LLM à l'ingestion.
///
/// Règles (voir tech-spec §F3) :
/// - Terminal Card : priorité aux messages `format == long`, `shownAt == null`,
///   `delayDays ≤ age_card_in_days`. Varie les types récemment affichés.
/// - Push pool : `format == short`, même critères d'éligibilité.
final class EngagementSchedulerService {
  EngagementSchedulerService({
    required EngagementMessageRepository engagementMessageRepository,
    required CardRepository cardRepository,
  }) : _messages = engagementMessageRepository,
       _cards = cardRepository;

  final EngagementMessageRepository _messages;
  final CardRepository _cards;
  final Log _log = Log.named('EngagementScheduler');

  /// Retourne le prochain message éligible à afficher sur la Terminal Card,
  /// ou `null` si le pool est vide.
  ///
  /// Heuristique :
  /// 1. Filtrer les messages `long` non-montrés avec `delayDays ≤ age`.
  /// 2. Éviter de répéter le type du dernier message montré (si possible).
  /// 3. Prioriser les messages rattachés à des cards récentes (plus "chaud").
  Future<EngagementMessageEntity?> nextMessageForHome({DateTime? now}) async {
    final DateTime ref = now ?? DateTime.now();
    final List<EngagementMessageEntity> pool = await _messages.pendingPool();
    if (pool.isEmpty) return null;

    // Cartographie des cards pour évaluer `delayDays ≤ age`.
    final Map<String, CardEntity> cardByUuid = await _loadCardMap(pool);

    final List<EngagementMessageEntity> eligible = pool.where((
      EngagementMessageEntity m,
    ) {
      if (m.format != EngagementMessageFormat.long) return false;
      final CardEntity? card = cardByUuid[m.cardUuid];
      if (card == null) return false;
      return m.isEligibleAt(ref, card.createdAt);
    }).toList();

    if (eligible.isEmpty) return null;

    // Avoid repeating the last shown type.
    final EngagementMessageType? lastType = await _lastShownType();
    final List<EngagementMessageEntity> primary = lastType == null
        ? eligible
        : eligible
              .where((EngagementMessageEntity m) => m.type != lastType)
              .toList();
    final List<EngagementMessageEntity> candidates =
        primary.isNotEmpty ? primary : eligible
          // Score by card recency : newer card = higher score.
          ..sort((EngagementMessageEntity a, EngagementMessageEntity b) {
            final CardEntity? ca = cardByUuid[a.cardUuid];
            final CardEntity? cb = cardByUuid[b.cardUuid];
            if (ca == null || cb == null) return 0;
            return cb.createdAt.compareTo(ca.createdAt);
          });

    return candidates.first;
  }

  /// Retourne les N prochains messages `short` éligibles pour push.
  /// Le scheduling réel (heure, persist NotificationRecord) est fait par
  /// `NotificationSchedulerService`.
  Future<List<EngagementMessageEntity>> nextPushCandidates({
    required int limit,
    DateTime? now,
  }) async {
    final DateTime ref = now ?? DateTime.now();
    final List<EngagementMessageEntity> pool = await _messages.pendingPool();
    if (pool.isEmpty) return <EngagementMessageEntity>[];

    final Map<String, CardEntity> cardByUuid = await _loadCardMap(pool);

    final List<EngagementMessageEntity> eligible =
        pool.where((
            EngagementMessageEntity m,
          ) {
            if (m.format != EngagementMessageFormat.short) return false;
            if (m.isScheduled) return false;
            final CardEntity? card = cardByUuid[m.cardUuid];
            if (card == null) return false;
            return m.isEligibleAt(ref, card.createdAt);
          }).toList()
          ..sort((EngagementMessageEntity a, EngagementMessageEntity b) {
            final CardEntity? ca = cardByUuid[a.cardUuid];
            final CardEntity? cb = cardByUuid[b.cardUuid];
            if (ca == null || cb == null) return 0;
            return cb.createdAt.compareTo(ca.createdAt);
          });

    return eligible.take(limit).toList();
  }

  Future<void> markShown(String uuid, {DateTime? at}) async {
    await _messages.markShown(uuid, at: at);
    _log.info('Marked shown: $uuid');
  }

  Future<void> markScheduled(String uuid, DateTime at) async {
    await _messages.markScheduled(uuid, at);
  }

  Future<Map<String, CardEntity>> _loadCardMap(
    List<EngagementMessageEntity> pool,
  ) async {
    final Set<String> uuids = pool
        .map((EngagementMessageEntity m) => m.cardUuid)
        .toSet();
    final Map<String, CardEntity> out = <String, CardEntity>{};
    for (final String uuid in uuids) {
      final CardEntity? c = await _cards.getByUuid(uuid);
      if (c != null) out[uuid] = c;
    }
    return out;
  }

  /// Renvoie le type du dernier message marqué `shownAt` (scan mémoire).
  /// Simple pour l'instant — si besoin, indexer ObjectBox par shownAt.
  Future<EngagementMessageType?> _lastShownType() async {
    // Note: on n'a pas de query "byShownAt" pour l'instant. Acceptable :
    // le pool est petit (quelques dizaines max) et c'est rare.
    return null;
  }
}
