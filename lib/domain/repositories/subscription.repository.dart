import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';

abstract interface class SubscriptionRepository {
  /// Charge l'état actuel d'abonnement (depuis RevenueCat + cache local).
  Future<SubscriptionSnapshotEntity> load();

  /// Sync depuis RevenueCat (appelle le SDK).
  Future<SubscriptionSnapshotEntity> refresh();

  Stream<SubscriptionSnapshotEntity> watch();

  /// Incrémente le compteur freemium mensuel.
  Future<void> incrementMonthlyGeneration();

  /// Achète un produit (monthly / yearly).
  Future<void> purchase(String productId);

  /// Restore purchases.
  Future<void> restore();
}
