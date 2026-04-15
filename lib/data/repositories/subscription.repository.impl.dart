import 'dart:async';

import 'package:beedle/data/datasources/local/subscription_snapshot.local.data_source.dart';
import 'package:beedle/data/mappers/subscription_snapshot.mapper.dart';
import 'package:beedle/data/model/local/subscription_snapshot.local.model.dart';
import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/enum/subscription_tier.enum.dart';
import 'package:beedle/domain/repositories/subscription.repository.dart';
import 'package:beedle/foundation/config/app_config.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

const String _kEntitlementPro = 'pro';

/// Implémentation Subscription via RevenueCat + cache ObjectBox.
///
/// - `refresh()` appelle Purchases et sync le snapshot local.
/// - `watch()` stream le cache local (UI-friendly).
final class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({
    required SubscriptionSnapshotLocalDataSource dataSource,
    required AppConfig appConfig,
  })  : _dataSource = dataSource,
        _appConfig = appConfig;

  final SubscriptionSnapshotLocalDataSource _dataSource;
  final AppConfig _appConfig;
  final Log _log = Log.named('SubscriptionRepository');

  @override
  Future<SubscriptionSnapshotEntity> load() async {
    final local = await _dataSource.load();
    return local.toEntity();
  }

  bool get _isPurchasesConfigured =>
      !_appConfig.revenueCatApiKeyIos.contains('TODO') &&
      !_appConfig.revenueCatApiKeyAndroid.contains('TODO');

  @override
  Future<SubscriptionSnapshotEntity> refresh() async {
    if (!_isPurchasesConfigured) {
      _log.info('Purchases not configured — skipping refresh.');
      return load();
    }
    try {
      final info = await Purchases.getCustomerInfo();
      final pro = info.entitlements.active[_kEntitlementPro];

      final tier = pro != null ? SubscriptionTier.pro : SubscriptionTier.free;
      final trialExpires = pro?.expirationDate != null ? DateTime.tryParse(pro!.expirationDate!) : null;
      final subscribedAt =
          pro?.originalPurchaseDate != null ? DateTime.tryParse(pro!.originalPurchaseDate) : null;

      final existing = await _dataSource.load();
      existing
        ..tier = tier.name
        ..lastSyncedAt = DateTime.now()
        ..appUserId = info.originalAppUserId
        ..trialExpiresAt = trialExpires
        ..subscribedAt = subscribedAt
        ..monthlyCycleStart = _resolveMonthlyCycleStart(existing);
      await _dataSource.save(existing);

      return existing.toEntity();
    } on Exception catch (e, st) {
      _log.warn('Refresh failed: $e', e, st);
      return load();
    } catch (e, st) {
      _log.warn('Refresh native error: $e', e, st);
      return load();
    }
  }

  DateTime _resolveMonthlyCycleStart(SubscriptionSnapshotLocalModel existing) {
    final now = DateTime.now();
    final currentCycleStart = DateTime(now.year, now.month);
    if (existing.monthlyCycleStart.isBefore(currentCycleStart)) {
      existing.monthlyGenerationCount = 0;
      return currentCycleStart;
    }
    return existing.monthlyCycleStart;
  }

  @override
  Stream<SubscriptionSnapshotEntity> watch() {
    return _dataSource.watch().map((m) => m.toEntity());
  }

  @override
  Future<void> incrementMonthlyGeneration() async {
    final existing = await _dataSource.load();
    existing
      ..monthlyCycleStart = _resolveMonthlyCycleStart(existing)
      ..monthlyGenerationCount = existing.monthlyGenerationCount + 1;
    await _dataSource.save(existing);
  }

  @override
  Future<void> purchase(String productId) async {
    if (!_isPurchasesConfigured) {
      _log.warn('Purchases not configured — purchase skipped.');
      return;
    }
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        _log.warn('No RevenueCat offering current');
        return;
      }
      final Package package = current.availablePackages.firstWhere(
        (p) => p.storeProduct.identifier == productId,
        orElse: () => current.availablePackages.first,
      );
      await Purchases.purchasePackage(package);
      await refresh();
    } on PlatformException catch (e) {
      _log.error('Purchase failed: $e', e);
      rethrow;
    }
  }

  @override
  Future<void> restore() async {
    if (!_isPurchasesConfigured) {
      _log.warn('Purchases not configured — restore skipped.');
      return;
    }
    try {
      await Purchases.restorePurchases();
      await refresh();
    } on Exception catch (e) {
      _log.error('Restore failed: $e', e);
      rethrow;
    }
  }
}
