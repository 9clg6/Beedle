import 'package:beedle/data/model/local/subscription_snapshot.local.model.dart';
import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/enum/subscription_tier.enum.dart';

extension SubscriptionSnapshotLocalModelX on SubscriptionSnapshotLocalModel {
  SubscriptionSnapshotEntity toEntity() => SubscriptionSnapshotEntity(
    tier: SubscriptionTier.fromString(tier),
    lastSyncedAt: lastSyncedAt,
    monthlyGenerationCount: monthlyGenerationCount,
    monthlyCycleStart: monthlyCycleStart,
    appUserId: appUserId,
    trialExpiresAt: trialExpiresAt,
    subscribedAt: subscribedAt,
  );
}

extension SubscriptionSnapshotEntityToLocalX on SubscriptionSnapshotEntity {
  SubscriptionSnapshotLocalModel toLocalModel() =>
      SubscriptionSnapshotLocalModel(
        tier: tier.name,
        lastSyncedAt: lastSyncedAt,
        monthlyGenerationCount: monthlyGenerationCount,
        monthlyCycleStart: monthlyCycleStart,
        appUserId: appUserId,
        trialExpiresAt: trialExpiresAt,
        subscribedAt: subscribedAt,
      );
}
