import 'package:beedle/domain/entities/activity_day.entity.dart';
import 'package:beedle/domain/entities/gamification_state.entity.dart';
import 'package:beedle/domain/entities/weekly_challenge.entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard.state.freezed.dart';

@Freezed(copyWith: true)
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    required GamificationStateEntity state,
    required List<ActivityDayEntity> days,
    WeeklyChallengeEntity? currentChallenge,
  }) = _DashboardState;

  factory DashboardState.initial() => DashboardState(
        state: GamificationStateEntity.initial(),
        days: const <ActivityDayEntity>[],
      );
}
