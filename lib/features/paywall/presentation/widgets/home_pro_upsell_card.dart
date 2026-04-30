import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/pro_status.provider.dart';
import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/services/scan_quota.service.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Card d'upsell Pro affichée sur la Home pour les users Free uniquement.
///
/// Comportement :
///   • Users Pro → ne rend rien (`SizedBox.shrink`).
///   • Users Free :
///       - Affiche un compteur dynamique de scans IA utilisés / restants
///         (lu depuis [SubscriptionSnapshotEntity.monthlyGenerationCount])
///       - Tap ouvre le paywall principal
///
/// Le design respecte CalmSurface : Ember mesh accent en background, glass
/// card 28 squircle, Doto pour les chiffres de quota, Hanken pour la copy.
/// Une seule Ember accent est autorisée par écran — cette card est pensée
/// pour être l'accent unique de la Home. Ne pas la combiner avec un autre
/// Ember accent (cf. §2.3 DESIGN.md).
class HomeProUpsellCard extends ConsumerWidget {
  const HomeProUpsellCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isPro = ref.watch(proStatusProvider).value ?? false;
    if (isPro) return const SizedBox.shrink();

    final AsyncValue<SubscriptionSnapshotEntity> snapshotAsync = ref.watch(
      _subscriptionSnapshotProvider,
    );

    return snapshotAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (SubscriptionSnapshotEntity snapshot) => _UpsellCard(
        used: snapshot.monthlyGenerationCount,
      ),
    );
  }
}

/// Fetch du snapshot d'abonnement (compteur + cycle mensuel).
///
/// On lit via `load()` plutôt que `watch()` car le compteur change rarement
/// (à chaque ingestion réussie), et un rebuild de la Home toutes les minutes
/// sur un stream n'apporte rien.
final FutureProvider<SubscriptionSnapshotEntity> _subscriptionSnapshotProvider =
    FutureProvider<SubscriptionSnapshotEntity>((Ref ref) async {
  return ref.watch(subscriptionRepositoryProvider).load();
});

class _UpsellCard extends StatelessWidget {
  const _UpsellCard({required this.used});

  final int used;

  int get _limit => ScanQuotaService.freeMonthlyLimit;
  int get _remaining => (_limit - used).clamp(0, _limit);
  bool get _atLimit => used >= _limit;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final SmoothBorderRadius radius = SmoothBorderRadius(
      cornerRadius: CalmRadius.xl2,
      cornerSmoothing: CalmRadius.smoothingFor(CalmRadius.xl2),
    );

    return ClipSmoothRect(
      radius: radius,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: SmoothRectangleBorder(borderRadius: radius),
          onTap: () => AutoRouter.of(context).push(const PaywallRoute()),
          child: Stack(
            children: <Widget>[
              // Ember mesh background — signature Ember Accent §2.3
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      radius: 1.4,
                      colors: <Color>[
                        Color(0xFFFF5A1F),
                        Color(0xFFFF8C42),
                        Color(0xFFFFB067),
                        Color(0xFFFFB067),
                      ],
                      stops: <double>[0, 0.35, 0.75, 1],
                    ),
                  ),
                ),
              ),
              // Glass subject card — contenu lisible par-dessus le mesh
              Padding(
                padding: const EdgeInsets.all(CalmSpace.s4),
                child: GlassCard(
                  elevated: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Header compact : eyebrow + pill chevron
                      Row(
                        children: <Widget>[
                          Text(
                            'BEEDLE · PRO',
                            style: AppTypography.mono(
                              const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: AppColors.ember,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                            color: AppColors.neutral7,
                          ),
                        ],
                      ),
                      const Gap(CalmSpace.s5),
                      // Titre — change selon l'état du quota
                      Text(
                        _atLimit
                            ? 'Tes cartes resteraient muettes'
                            : 'Fais chanter toutes tes cartes',
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.neutral8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                      ),
                      const Gap(CalmSpace.s3),
                      Text(
                        _atLimit
                            ? 'Tu as utilisé tes $_limit scans IA du mois. '
                                  'Passe Pro pour scanner sans limite.'
                            : 'Scan IA illimité, recherche par le sens, '
                                  'rappels adaptatifs, export.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral6,
                          height: 1.5,
                        ),
                      ),
                      const Gap(CalmSpace.s5),
                      _QuotaProgress(used: used, total: _limit),
                      const Gap(CalmSpace.s3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _atLimit
                                ? 'Quota épuisé'
                                : '$_remaining scans restants ce mois-ci',
                            style: textTheme.bodySmall?.copyWith(
                              color: _atLimit
                                  ? AppColors.ember
                                  : AppColors.neutral6,
                              fontWeight: _atLimit
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          Text(
                            '29,99 €/an',
                            style: AppTypography.mono(
                              const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barre de progression segmentée §3 Progress — Nothing-style.
/// 15 pills, une par scan possible. Active = ink, inactive = neutral.2.
class _QuotaProgress extends StatelessWidget {
  const _QuotaProgress({required this.used, required this.total});

  final int used;
  final int total;

  @override
  Widget build(BuildContext context) {
    final int filled = used.clamp(0, total);
    return Row(
      children: <Widget>[
        for (int i = 0; i < total; i++) ...<Widget>[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i < filled ? AppColors.ink : AppColors.neutral3,
                borderRadius: BorderRadius.circular(CalmRadius.pill),
              ),
            ),
          ),
          if (i < total - 1) const SizedBox(width: 2),
        ],
      ],
    );
  }
}
