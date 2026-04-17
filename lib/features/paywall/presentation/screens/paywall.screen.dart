import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/auth.provider.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_back_button.dart';
import 'package:beedle/presentation/widgets/calm_badge.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

@RoutePage()
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 60,
        leading: const CalmCloseButton(),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(CalmSpace.s7),
            children: <Widget>[
              const Gap(CalmSpace.s5),
              // Eyebrow
              const CalmBadge(
                label: 'BEEDLE PRO',
                variant: CalmBadgeVariant.mint,
              ),
              const Gap(CalmSpace.s5),
              // Title — display.md ink flat.
              Text(
                LocaleKeys.paywall_title.tr(),
                style: textTheme.displaySmall?.copyWith(
                  color: AppColors.ink,
                  height: 1.1,
                ),
              ),
              const Gap(CalmSpace.s4),
              Text(
                LocaleKeys.paywall_subtitle.tr(),
                style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
              ),
              const Gap(CalmSpace.s8),
              // Benefits list — no gradient circles, neutral tokens only.
              GlassCard(
                elevated: false,
                child: Column(
                  children: <Widget>[
                    _Benefit(
                      icon: Icons.all_inclusive_rounded,
                      label: LocaleKeys.paywall_benefits_unlimited.tr(),
                    ),
                    const _BenefitDivider(),
                    _Benefit(
                      icon: Icons.search_rounded,
                      label: LocaleKeys.paywall_benefits_search.tr(),
                    ),
                    const _BenefitDivider(),
                    _Benefit(
                      icon: Icons.notifications_active_rounded,
                      label: LocaleKeys.paywall_benefits_notifications.tr(),
                    ),
                    const _BenefitDivider(),
                    _Benefit(
                      icon: Icons.favorite_rounded,
                      label: LocaleKeys.paywall_benefits_support.tr(),
                    ),
                  ],
                ),
              ),
              const Gap(CalmSpace.s7),
              // Primary CTA — mint pill (marketing surface).
              SquircleButton(
                label: LocaleKeys.paywall_trial_cta.tr(),
                variant: SquircleButtonVariant.mint,
                expand: true,
                onPressed: () => _onTapSubscribe(context, ref),
              ),
              const Gap(CalmSpace.s3),
              SquircleButton(
                label: LocaleKeys.settings_restore_purchases.tr(),
                variant: SquircleButtonVariant.ghost,
                expand: true,
                onPressed: () =>
                    ref.read(subscriptionRepositoryProvider).restore(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gate l'achat sur l'auth : si l'utilisateur est anonyme, on push
/// `AuthRoute(required: true)` et on retry l'achat au retour si signed-in.
Future<void> _onTapSubscribe(BuildContext context, WidgetRef ref) async {
  AuthUserEntity? user = ref.read(currentUserProvider);
  if (user == null) {
    await context.router.push(AuthRoute(required: true));
    if (!context.mounted) return;
    user = ref.read(currentUserProvider);
    if (user == null) return; // user a backé sans s'auth
  }
  try {
    await ref
        .read(subscriptionRepositoryProvider)
        .purchase('beedle_pro_yearly');
    if (context.mounted) unawaited(context.router.maybePop());
  } on Exception catch (_) {}
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CalmSpace.s4),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.neutral7),
          const Gap(CalmSpace.s5),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.neutral8),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitDivider extends StatelessWidget {
  const _BenefitDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.neutral2,
    );
  }
}
