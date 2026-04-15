import 'package:objectbox/objectbox.dart';

@Entity()
class SubscriptionSnapshotLocalModel {
  SubscriptionSnapshotLocalModel({
    required this.lastSyncedAt, required this.monthlyCycleStart, this.id = 1, // singleton
    this.tier = 'free',
    this.monthlyGenerationCount = 0,
    this.appUserId,
    this.trialExpiresAt,
    this.subscribedAt,
  });

  @Id(assignable: true)
  int id;

  String tier;

  @Property(type: PropertyType.date)
  DateTime lastSyncedAt;

  int monthlyGenerationCount;

  @Property(type: PropertyType.date)
  DateTime monthlyCycleStart;

  String? appUserId;

  @Property(type: PropertyType.date)
  DateTime? trialExpiresAt;

  @Property(type: PropertyType.date)
  DateTime? subscribedAt;
}
