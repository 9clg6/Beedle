import 'package:beedle/domain/entities/activity_day.entity.dart';
import 'package:beedle/domain/entities/gamification_state.entity.dart';
import 'package:beedle/domain/entities/weekly_challenge.entity.dart';

abstract interface class GamificationRepository {
  // State global.
  Future<GamificationStateEntity> loadState();
  Future<void> saveState(GamificationStateEntity state);
  Stream<GamificationStateEntity> watchState();

  // Activity log.
  Future<ActivityDayEntity> todayActivity();
  Future<void> upsertActivity(ActivityDayEntity day);
  Future<List<ActivityDayEntity>> last(int days);

  // Weekly challenge.
  Future<WeeklyChallengeEntity?> currentChallenge();
  Future<void> saveChallenge(WeeklyChallengeEntity challenge);

  // Wipe (RGPD).
  Future<void> wipe();
}
