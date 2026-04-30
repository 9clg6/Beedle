import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/scan_quota.provider.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/domain/services/scan_quota.service.dart';
import 'package:beedle/features/paywall/presentation/widgets/contextual_paywall_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper d'orchestration pour toute action qui consomme un scan IA.
///
/// Usage type dans un ViewModel :
/// ```dart
/// final ok = await ScanGate.of(ref).requestPermission(context);
/// if (!ok) return;
/// final result = await _runScan(...);
/// await ScanGate.of(ref).confirmConsumed();
/// ```
///
/// Flow :
///   1. `requestPermission()` interroge [ScanQuotaService].
///   2. Si `allowed` → renvoie `true` tout de suite.
///   3. Si `warning` → renvoie `true`, mais l'appelant peut afficher
///      un toast discret "Il te reste N scans".
///   4. Si `blocked` → ouvre le bottom sheet paywall contextuel
///      ([ContextualPaywallReason.scanQuotaReached]) et renvoie `false`.
///   5. Après exécution réelle du scan, appeler `confirmConsumed()` pour
///      incrémenter le compteur mensuel (no-op si Pro).
class ScanGate {
  ScanGate._(this._ref);

  final WidgetRef _ref;

  static ScanGate of(WidgetRef ref) => ScanGate._(ref);

  Future<bool> requestPermission(BuildContext context) async {
    final bool isPro = await _isPro();
    final ScanQuotaService service = _ref.read(scanQuotaServiceProvider);
    final ScanDecision decision = await service.evaluate(isPro: isPro);

    return switch (decision) {
      ScanAllowed() => true,
      ScanWarning() => true, // allow, l'UI peut choisir d'afficher un hint
      ScanBlocked(reason: ScanBlockedReason.monthlyLimitReached) => () async {
          await _ref
              .read(analyticsServiceProvider)
              .track(
                AnalyticsEvent.freemiumCapReached,
                properties: <String, Object>{
                  'limit': ScanQuotaService.freeMonthlyLimit,
                },
              );
          if (!context.mounted) return false;
          await showContextualPaywall(
            context,
            reason: ContextualPaywallReason.scanQuotaReached,
            quotaLimit: ScanQuotaService.freeMonthlyLimit,
          );
          return false;
        }(),
    };
  }

  Future<void> confirmConsumed() async {
    final bool isPro = await _isPro();
    await _ref.read(scanQuotaServiceProvider).consume(isPro: isPro);
  }

  /// Consulte la décision sans ouvrir de paywall. Utile pour afficher un
  /// compteur dans la UI ("3 scans restants ce mois").
  Future<ScanDecision> peek() async {
    final bool isPro = await _isPro();
    return _ref.read(scanQuotaServiceProvider).evaluate(isPro: isPro);
  }

  Future<bool> _isPro() async {
    final SubscriptionSnapshotEntity snapshot =
        await _ref.read(subscriptionRepositoryProvider).load();
    return snapshot.isPro;
  }
}
