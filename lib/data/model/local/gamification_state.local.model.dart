import 'package:objectbox/objectbox.dart';

@Entity()
class GamificationStateLocalModel {
  GamificationStateLocalModel({
    this.id = 1, // singleton
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.freezeDaysUsedThisMonth = 0,
    this.unlockedBadgesJson = '[]',
    this.lastActiveDay,
  });

  @Id(assignable: true)
  int id;

  int totalXp;
  int currentStreak;
  int longestStreak;
  int freezeDaysUsedThisMonth;
  String unlockedBadgesJson;

  @Property(type: PropertyType.date)
  DateTime? lastActiveDay;
}
