import 'package:beedle/domain/enum/subscription_tier.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_snapshot.entity.freezed.dart';

/// Entité snapshot d'abonnement — synchronisée via RevenueCat.
@freezed
abstract class SubscriptionSnapshotEntity with _$SubscriptionSnapshotEntity {
  const factory SubscriptionSnapshotEntity({
    required SubscriptionTier tier,
    required DateTime lastSyncedAt,
    required int monthlyGenerationCount,
    required DateTime monthlyCycleStart,
    String? appUserId,
    DateTime? trialExpiresAt,
    DateTime? subscribedAt,
  }) = _SubscriptionSnapshotEntity;

  factory SubscriptionSnapshotEntity.initial() => SubscriptionSnapshotEntity(
        tier: SubscriptionTier.free,
        lastSyncedAt: DateTime.now(),
        monthlyGenerationCount: 0,
        monthlyCycleStart: DateTime(DateTime.now().year, DateTime.now().month),
      );
}

extension SubscriptionSnapshotEntityX on SubscriptionSnapshotEntity {
  bool get isPro => tier.isPro;

  bool get isInTrial {
    final expires = trialExpiresAt;
    if (expires == null) return false;
    return expires.isAfter(DateTime.now());
  }
}
