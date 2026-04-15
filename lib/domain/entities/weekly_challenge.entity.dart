import 'package:beedle/domain/enum/challenge_type.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekly_challenge.entity.freezed.dart';

/// Défi hebdomadaire — reset chaque lundi.
@freezed
abstract class WeeklyChallengeEntity with _$WeeklyChallengeEntity {
  const factory WeeklyChallengeEntity({
    required DateTime weekStart,
    required ChallengeType type,
    required int target,
    @Default(0) int progress,
    DateTime? completedAt,
  }) = _WeeklyChallengeEntity;
}

extension WeeklyChallengeEntityX on WeeklyChallengeEntity {
  bool get isCompleted => completedAt != null;
  double get progressRatio => target == 0 ? 0 : (progress / target).clamp(0.0, 1.0);
}
