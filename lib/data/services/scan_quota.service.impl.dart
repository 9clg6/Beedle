import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/repositories/subscription.repository.dart';
import 'package:beedle/domain/services/scan_quota.service.dart';

/// Implémentation de [ScanQuotaService] qui s'appuie sur le
/// [SubscriptionRepository] pour lire/incrémenter le compteur mensuel.
///
/// Le repo gère déjà le reset du compteur au changement de mois calendaire
/// (cf. `_resolveMonthlyCycleStart` côté subscription.repository.impl.dart).
/// On ne fait ici que traduire le state en décision.
final class ScanQuotaServiceImpl implements ScanQuotaService {
  ScanQuotaServiceImpl({required SubscriptionRepository subscriptionRepo})
      : _subscriptionRepo = subscriptionRepo;

  final SubscriptionRepository _subscriptionRepo;

  @override
  Future<ScanDecision> evaluate({required bool isPro}) async {
    if (isPro) {
      return const ScanDecision.allowed();
    }
    final SubscriptionSnapshotEntity snapshot = await _subscriptionRepo.load();
    final int used = snapshot.monthlyGenerationCount;
    const int limit = ScanQuotaService.freeMonthlyLimit;

    if (used >= limit) {
      return const ScanDecision.blocked(
        reason: ScanBlockedReason.monthlyLimitReached,
      );
    }

    final int remaining = limit - used;
    if (used >= ScanQuotaService.freeWarningThreshold) {
      return ScanDecision.warning(remaining: remaining);
    }
    return ScanDecision.allowed(remaining: remaining);
  }

  @override
  Future<void> consume({required bool isPro}) async {
    if (isPro) return;
    await _subscriptionRepo.incrementMonthlyGeneration();
  }
}
