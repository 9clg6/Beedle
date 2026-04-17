import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/enum/subscription_tier.enum.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_badge.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Product identifiers configurés dans RevenueCat dashboard. Si les
/// clés API contiennent "TODO" la repo skip silencieusement et le
/// purchase reste un no-op — l'user peut continuer en gratuit.
const String _kMonthlyProductId = 'beedle_pro_monthly';
const String _kYearlyProductId = 'beedle_pro_yearly';

enum _Plan { monthly, yearly }

/// Écran 15 — Paywall (RevenueCat + fallback gratuit).
class OnboardingPaywallStep extends ConsumerStatefulWidget {
  const OnboardingPaywallStep({super.key});

  @override
  ConsumerState<OnboardingPaywallStep> createState() =>
      _OnboardingPaywallStepState();
}

class _OnboardingPaywallStepState extends ConsumerState<OnboardingPaywallStep> {
  _Plan _selectedPlan = _Plan.yearly;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(analyticsServiceProvider)
          .track(
            AnalyticsEvent.paywallShown,
            properties: const <String, Object>{'source': 'onboarding'},
          );
    });
  }

  Future<void> _finishToHome() async {
    await ref.read(onboardingViewModelProvider.notifier).finishOnboarding();
    if (!mounted) return;
    await context.router.replace(const HomeRoute());
  }

  Future<void> _onStartTrial() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final String productId = _selectedPlan == _Plan.yearly
          ? _kYearlyProductId
          : _kMonthlyProductId;
      await ref.read(subscriptionRepositoryProvider).purchase(productId);
      await ref
          .read(analyticsServiceProvider)
          .track(
            AnalyticsEvent.trialStarted,
            properties: <String, Object>{'product_id': productId},
          );
      await _finishToHome();
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.onboarding_ob15_error_purchase.tr()),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onContinueFree() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _finishToHome();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onRestore() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(subscriptionRepositoryProvider).restore();
      final SubscriptionSnapshotEntity snapshot = await ref
          .read(subscriptionRepositoryProvider)
          .load();
      if (snapshot.tier == SubscriptionTier.pro) {
        await ref
            .read(analyticsServiceProvider)
            .track(AnalyticsEvent.subscriptionRestored);
        await _finishToHome();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.onboarding_ob15_error_restore.tr()),
          ),
        );
      }
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.onboarding_ob15_error_restore.tr()),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s7,
        CalmSpace.s7,
        CalmSpace.s7,
        CalmSpace.s5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const CalmBadge(label: 'BEEDLE PRO', variant: CalmBadgeVariant.mint),
          const Gap(CalmSpace.s5),
          Text(
            LocaleKeys.onboarding_ob15_title.tr(),
            style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s5),
          GlassCard(
            elevated: false,
            padding: const EdgeInsets.all(CalmSpace.s4),
            child: Text(
              LocaleKeys.onboarding_ob15_testimonial.tr(),
              style: textTheme.bodyMedium?.copyWith(color: AppColors.neutral8),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(CalmSpace.s7),
          _PlanTile(
            label: LocaleKeys.onboarding_ob15_yearly_label.tr(),
            price: LocaleKeys.onboarding_ob15_yearly_price.tr(),
            period: LocaleKeys.onboarding_ob15_yearly_period.tr(),
            badge: LocaleKeys.onboarding_ob15_yearly_badge.tr(),
            selected: _selectedPlan == _Plan.yearly,
            onTap: () => setState(() => _selectedPlan = _Plan.yearly),
          ),
          const Gap(CalmSpace.s3),
          _PlanTile(
            label: LocaleKeys.onboarding_ob15_monthly_label.tr(),
            price: LocaleKeys.onboarding_ob15_monthly_price.tr(),
            period: LocaleKeys.onboarding_ob15_monthly_period.tr(),
            selected: _selectedPlan == _Plan.monthly,
            onTap: () => setState(() => _selectedPlan = _Plan.monthly),
          ),
          const Gap(CalmSpace.s7),
          SquircleButton(
            label: LocaleKeys.onboarding_ob15_cta_trial.tr(),
            variant: SquircleButtonVariant.mint,
            expand: true,
            loading: _busy,
            onPressed: _onStartTrial,
          ),
          const Gap(CalmSpace.s2),
          SquircleButton(
            label: LocaleKeys.onboarding_ob15_cta_free.tr(),
            variant: SquircleButtonVariant.ghost,
            expand: true,
            onPressed: _onContinueFree,
          ),
          const Gap(CalmSpace.s2),
          TextButton(
            onPressed: _onRestore,
            child: Text(
              LocaleKeys.onboarding_ob15_cta_restore.tr(),
              style: textTheme.labelMedium?.copyWith(color: AppColors.neutral6),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.label,
    required this.price,
    required this.period,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final String price;
  final String period;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isMint = badge != null;
    final Color background = selected
        ? (isMint ? AppColors.mint : AppColors.ink)
        : AppColors.glassSoft;
    final Color foreground = selected
        ? (isMint ? AppColors.ink : AppColors.canvas)
        : AppColors.ink;
    final Color subForeground = selected
        ? (isMint ? AppColors.ink : AppColors.mint)
        : AppColors.neutral6;

    final String semanticsLabel = badge != null
        ? '$label, $price$period, $badge'
        : '$label, $price$period';
    return Semantics(
      label: semanticsLabel,
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CalmRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(CalmSpace.s5),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(CalmRadius.lg),
              border: selected ? null : Border.all(color: AppColors.neutral3),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        label,
                        style: textTheme.titleMedium?.copyWith(
                          color: foreground,
                        ),
                      ),
                      if (badge != null)
                        Padding(
                          padding: const EdgeInsets.only(top: CalmSpace.s1),
                          child: Text(
                            badge!.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              color: subForeground,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: textTheme.headlineMedium?.copyWith(color: foreground),
                ),
                Text(
                  period,
                  style: textTheme.bodyMedium?.copyWith(color: subForeground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
