import 'dart:convert';

import 'package:beedle/data/model/local/activity_day.local.model.dart';
import 'package:beedle/data/model/local/gamification_state.local.model.dart';
import 'package:beedle/data/model/local/weekly_challenge.local.model.dart';
import 'package:beedle/domain/entities/activity_day.entity.dart';
import 'package:beedle/domain/entities/gamification_state.entity.dart';
import 'package:beedle/domain/entities/weekly_challenge.entity.dart';
import 'package:beedle/domain/enum/badge_type.enum.dart';
import 'package:beedle/domain/enum/challenge_type.enum.dart';

extension GamificationStateLocalModelX on GamificationStateLocalModel {
  GamificationStateEntity toEntity() {
    final badges = (jsonDecode(unlockedBadgesJson) as List<dynamic>)
        .map((dynamic e) => BadgeType.fromString(e.toString()))
        .toList();
    return GamificationStateEntity(
      totalXp: totalXp,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      freezeDaysUsedThisMonth: freezeDaysUsedThisMonth,
      unlockedBadges: badges,
      lastActiveDay: lastActiveDay,
    );
  }
}

extension GamificationStateEntityToLocalX on GamificationStateEntity {
  GamificationStateLocalModel toLocalModel() => GamificationStateLocalModel(
        totalXp: totalXp,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        freezeDaysUsedThisMonth: freezeDaysUsedThisMonth,
        unlockedBadgesJson: jsonEncode(unlockedBadges.map((b) => b.name).toList()),
        lastActiveDay: lastActiveDay,
      );
}

extension ActivityDayLocalModelX on ActivityDayLocalModel {
  ActivityDayEntity toEntity() => ActivityDayEntity(
        day: dayEpoch,
        cardsImported: cardsImported,
        cardsViewed: cardsViewed,
        cardsTested: cardsTested,
      );
}

extension ActivityDayEntityToLocalX on ActivityDayEntity {
  ActivityDayLocalModel toLocalModel({int? id}) => ActivityDayLocalModel(
        id: id ?? 0,
        dayEpoch: day,
        cardsImported: cardsImported,
        cardsViewed: cardsViewed,
        cardsTested: cardsTested,
      );
}

extension WeeklyChallengeLocalModelX on WeeklyChallengeLocalModel {
  WeeklyChallengeEntity toEntity() => WeeklyChallengeEntity(
        weekStart: weekStart,
        type: ChallengeType.fromString(type),
        target: target,
        progress: progress,
        completedAt: completedAt,
      );
}

extension WeeklyChallengeEntityToLocalX on WeeklyChallengeEntity {
  WeeklyChallengeLocalModel toLocalModel({int? id}) => WeeklyChallengeLocalModel(
        id: id ?? 0,
        weekStart: weekStart,
        type: type.name,
        target: target,
        progress: progress,
        completedAt: completedAt,
      );
}
