import 'package:beedle/domain/entities/activity_day.entity.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/gamification_state.entity.dart';
import 'package:beedle/domain/entities/weekly_challenge.entity.dart';
import 'package:beedle/domain/enum/badge_type.enum.dart';
import 'package:beedle/domain/enum/challenge_type.enum.dart';
import 'package:beedle/domain/enum/xp_event.enum.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/domain/repositories/gamification.repository.dart';
import 'package:beedle/foundation/logging/logger.dart';

/// Orchestrateur gamification.
///
/// Hooked dans les use cases existants :
/// - `ImportScreenshotsUseCase` appelle [onImport]
/// - `MarkCardViewedUseCase` appelle [onCardViewed]
/// - `MarkCardTestedUseCase` appelle [onCardTested]
final class GamificationEngine {
  GamificationEngine({
    required GamificationRepository gamificationRepository,
    required CardRepository cardRepository,
  })  : _repo = gamificationRepository,
        _cardRepository = cardRepository;

  final GamificationRepository _repo;
  final CardRepository _cardRepository;
  final Log _log = Log.named('GamificationEngine');

  Future<void> onImport() => _process(
        event: XpEvent.cardImported,
        cardsImportedDelta: 1,
      );

  Future<void> onCardViewed(CardEntity card) async {
    await _process(
      event: XpEvent.cardViewed,
      cardsViewedDelta: 1,
      contextCard: card,
    );
  }

  Future<void> onCardTested(CardEntity card) async {
    await _process(
      event: XpEvent.cardTested,
      cardsTestedDelta: 1,
      contextCard: card,
      tested: true,
    );
    await _advanceChallenge(ChallengeType.testN);
  }

  Future<void> _process({
    required XpEvent event,
    int cardsImportedDelta = 0,
    int cardsViewedDelta = 0,
    int cardsTestedDelta = 0,
    CardEntity? contextCard,
    bool tested = false,
  }) async {
    final current = await _repo.loadState();
    final today = await _repo.todayActivity();

    // 1. Update activity log du jour.
    final updatedDay = today.copyWith(
      cardsImported: today.cardsImported + cardsImportedDelta,
      cardsViewed: today.cardsViewed + cardsViewedDelta,
      cardsTested: today.cardsTested + cardsTestedDelta,
    );
    await _repo.upsertActivity(updatedDay);

    // 2. Compute new streak.
    final newStreak = _computeNewStreak(
      lastActiveDay: current.lastActiveDay,
      currentStreak: current.currentStreak,
    );

    // 3. XP + bonus streak si le streak a progressé.
    var bonusXp = 0;
    if (newStreak > current.currentStreak && newStreak > 1) {
      bonusXp = XpEvent.streakBonus.points;
    }
    final newXp = current.totalXp + event.points + bonusXp;

    // 4. Évaluer badges.
    final unlocked = <BadgeType>{...current.unlockedBadges};
    _awardIf(unlocked, BadgeType.firstImport, () => cardsImportedDelta > 0);
    _awardIf(unlocked, BadgeType.firstTest, () => cardsTestedDelta > 0);
    _awardIf(unlocked, BadgeType.streak3, () => newStreak >= 3);
    _awardIf(unlocked, BadgeType.streak7, () => newStreak >= 7);
    _awardIf(unlocked, BadgeType.streak30, () => newStreak >= 30);

    final hour = DateTime.now().hour;
    _awardIf(unlocked, BadgeType.earlyBird, () => hour < 9);
    _awardIf(unlocked, BadgeType.nightOwl, () => hour >= 20 && hour < 22);

    final totalCards = await _cardRepository.count();
    _awardIf(unlocked, BadgeType.collector50, () => totalCards >= 50);
    _awardIf(unlocked, BadgeType.collector200, () => totalCards >= 200);

    // Deep dive / archaeologist / polyglot / sensei — contextuels.
    if (contextCard != null) {
      _awardIf(unlocked, BadgeType.deepDive, () => contextCard.viewedCount > 1);
      if (DateTime.now().difference(contextCard.createdAt).inDays > 30) {
        _awardIf(unlocked, BadgeType.archaeologist, () => true);
        await _advanceChallenge(ChallengeType.reviveOld);
      }
    }
    if (tested) {
      final testedCount = await _countTestedCards();
      _awardIf(unlocked, BadgeType.apprentice, () => testedCount >= 5);
      _awardIf(unlocked, BadgeType.sensei, () => testedCount >= 25);
    }

    // 5. Persist.
    final newState = current.copyWith(
      totalXp: newXp,
      currentStreak: newStreak,
      longestStreak: newStreak > current.longestStreak ? newStreak : current.longestStreak,
      unlockedBadges: unlocked.toList(),
      lastActiveDay: _todayMidnight(),
    );
    await _repo.saveState(newState);

    _log.info(
      'Gamification: +${event.points + bonusXp} XP (total ${newState.totalXp}), '
      'streak $newStreak, badges=${unlocked.length}',
    );
  }

  int _computeNewStreak({required DateTime? lastActiveDay, required int currentStreak}) {
    if (lastActiveDay == null) return 1;
    final today = _todayMidnight();
    final last = DateTime(lastActiveDay.year, lastActiveDay.month, lastActiveDay.day);
    final diffDays = today.difference(last).inDays;
    if (diffDays == 0) return currentStreak == 0 ? 1 : currentStreak; // déjà actif aujourd'hui
    if (diffDays == 1) return currentStreak + 1; // continuité
    return 1; // reset
  }

  Future<int> _countTestedCards() async {
    final all = await _cardRepository.getAll();
    return all.where((c) => c.isTested).length;
  }

  Future<void> _advanceChallenge(ChallengeType expected) async {
    var challenge = await _repo.currentChallenge();
    challenge ??= WeeklyChallengeEntity(
      weekStart: _currentWeekStart(),
      type: expected,
      target: _defaultTargetFor(expected),
    );
    if (challenge.type != expected) return;
    if (challenge.isCompleted) return;

    final newProgress = challenge.progress + 1;
    final justCompleted = newProgress >= challenge.target;

    final updated = challenge.copyWith(
      progress: newProgress,
      completedAt: justCompleted ? DateTime.now() : null,
    );
    await _repo.saveChallenge(updated);

    if (justCompleted) {
      final s = await _repo.loadState();
      final unlocked = <BadgeType>{
        ...s.unlockedBadges,
        BadgeType.challengeRookie,
      };
      await _repo.saveState(s.copyWith(
        totalXp: s.totalXp + XpEvent.weeklyChallengeCompleted.points,
        unlockedBadges: unlocked.toList(),
      ));
      _log.info('Weekly challenge completed → +${XpEvent.weeklyChallengeCompleted.points} XP');
    }
  }

  int _defaultTargetFor(ChallengeType t) {
    switch (t) {
      case ChallengeType.testN:
        return 2;
      case ChallengeType.reviveOld:
        return 3;
      case ChallengeType.streakN:
        return 5;
    }
  }

  void _awardIf(Set<BadgeType> unlocked, BadgeType badge, bool Function() cond) {
    if (!unlocked.contains(badge) && cond()) {
      unlocked.add(badge);
      _log.info('Badge unlocked: ${badge.name}');
    }
  }

  DateTime _todayMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _currentWeekStart() {
    final today = _todayMidnight();
    return today.subtract(Duration(days: today.weekday - 1));
  }
}
