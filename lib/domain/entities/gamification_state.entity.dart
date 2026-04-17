import 'package:beedle/domain/enum/badge_type.enum.dart';
import 'package:beedle/domain/enum/beedle_level.enum.dart';
import 'package:beedle/domain/services/gamification_engine.service.dart'
    show GamificationEngine;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gamification_state.entity.freezed.dart';

/// État agrégé de gamification pour l'utilisateur.
///
/// Mis à jour par [GamificationEngine] à chaque event (import, view, test,
/// challenge complété). Stocké en singleton ObjectBox.
@freezed
abstract class GamificationStateEntity with _$GamificationStateEntity {
  const factory GamificationStateEntity({
    @Default(0) int totalXp,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    @Default(0) int freezeDaysUsedThisMonth,
    @Default(<BadgeType>[]) List<BadgeType> unlockedBadges,
    DateTime? lastActiveDay,
  }) = _GamificationStateEntity;

  factory GamificationStateEntity.initial() => const GamificationStateEntity();
}

extension GamificationStateEntityX on GamificationStateEntity {
  BeedleLevel get level => BeedleLevel.fromXp(totalXp);

  double get progressToNextLevel => level.progressToNext(totalXp);

  bool hasBadge(BadgeType type) => unlockedBadges.contains(type);
}
