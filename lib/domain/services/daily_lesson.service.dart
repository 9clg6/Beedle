import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/enum/card_intent.enum.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/foundation/logging/logger.dart';

/// Domain service — sélectionne la "Leçon du jour" à partir du pool de
/// cards `intent == apply` non testées.
///
/// Règles de sélection (voir brainstorming §Category 2) :
/// 1. Pool : `intent == apply` && `testedAt == null` && `isGenerated`
/// 2. Exclure la card proposée "récemment" (dernière 3 jours)
/// 3. Sort by recency DESC — fresh wins
/// 4. Fallback : card `apply` la plus anciennement vue si tout a été testé
final class DailyLessonService {
  DailyLessonService({required CardRepository cardRepository})
    : _cards = cardRepository;

  final CardRepository _cards;
  final Log _log = Log.named('DailyLesson');

  /// Historique simple en mémoire : dernier uuid proposé + date.
  /// Persisté in-memory (suffisant pour le cas "pas 2 jours d'affilée").
  _RecentPick? _lastPick;

  Future<CardEntity?> pickTodayLesson({DateTime? now}) async {
    final DateTime ref = now ?? DateTime.now();
    final List<CardEntity> all = await _cards.getAll();

    // 1. Pool éligible (apply + non testé + généré).
    final List<CardEntity> pool = all
        .where((CardEntity c) => c.isDailyLessonEligible)
        .toList();

    if (pool.isEmpty) {
      // Fallback : vieille apply déjà vue pour "re-practice".
      final List<CardEntity> fallback =
          all
              .where(
                (CardEntity c) =>
                    c.isGenerated &&
                    c.intent == CardIntent.apply &&
                    c.viewedAt != null,
              )
              .toList()
            ..sort((CardEntity a, CardEntity b) {
              final DateTime av = a.viewedAt ?? DateTime(2000);
              final DateTime bv = b.viewedAt ?? DateTime(2000);
              return av.compareTo(bv); // oldest viewed first
            });
      final CardEntity? pick = fallback.isEmpty ? null : fallback.first;
      if (pick != null) _rememberPick(pick, ref);
      return pick;
    }

    // 2. Exclure la card proposée il y a < 3 jours (si possible).
    final String? skipUuid =
        _lastPick != null && ref.difference(_lastPick!.at).inDays < 3
        ? _lastPick!.uuid
        : null;

    List<CardEntity> candidates = pool;
    if (skipUuid != null && pool.length > 1) {
      candidates = pool.where((CardEntity c) => c.uuid != skipUuid).toList();
    }

    // 3. Sort by recency DESC (createdAt).
    candidates.sort(
      (CardEntity a, CardEntity b) => b.createdAt.compareTo(a.createdAt),
    );

    final CardEntity? pick = candidates.isEmpty ? null : candidates.first;
    if (pick != null) _rememberPick(pick, ref);
    _log.info(
      'pickTodayLesson → ${pick?.uuid ?? "none"} '
      '(pool=${pool.length}, fallbackUsed=${pool.isEmpty})',
    );
    return pick;
  }

  void _rememberPick(CardEntity c, DateTime at) {
    _lastPick = _RecentPick(c.uuid, at);
  }
}

class _RecentPick {
  const _RecentPick(this.uuid, this.at);
  final String uuid;
  final DateTime at;
}
