import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_bullet.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_digital_number.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

const List<String> _kBulletKeys = <String>[
  LocaleKeys.onboarding_ob11_bullet0,
  LocaleKeys.onboarding_ob11_bullet1,
  LocaleKeys.onboarding_ob11_bullet2,
];

/// Écran 11 — Permission Notifications primer (preview mockup + soft-ask).
///
/// `requestNotifications()` appelle `localNotificationEngine.requestPermission()`.
class OnboardingPermissionNotifsStep extends ConsumerWidget {
  const OnboardingPermissionNotifsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingViewModelProvider);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s7,
        CalmSpace.s7,
        CalmSpace.s7,
        CalmSpace.s5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CalmDigitalNumber(
            value: LocaleKeys.onboarding_ob11_eyebrow.tr(),
            size: 18,
            color: AppColors.ember,
            letterSpacing: 4,
          ),
          const Gap(CalmSpace.s4),
          Text(
            LocaleKeys.onboarding_ob11_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s4),
          Text(
            LocaleKeys.onboarding_ob11_subtitle.tr(),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
          ),
          const Gap(CalmSpace.s5),
          // Mockup notif
          GlassCard(
            elevated: false,
            padding: const EdgeInsets.all(CalmSpace.s4),
            child: Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.ember.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(CalmRadius.sm),
                  ),
                  child: const Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.ember,
                    size: 20,
                  ),
                ),
                const Gap(CalmSpace.s3),
                Expanded(
                  child: Text(
                    LocaleKeys.onboarding_ob11_preview_title.tr(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(CalmSpace.s7),
          for (final String k in _kBulletKeys) ...<Widget>[
            ObBullet(text: k.tr()),
            const Gap(CalmSpace.s3),
          ],
          const Gap(CalmSpace.s7),
          Semantics(
            label: LocaleKeys.onboarding_ob11_cta_allow.tr(),
            button: true,
            child: SquircleButton(
              label: LocaleKeys.onboarding_ob11_cta_allow.tr(),
              icon: state.notificationsGranted
                  ? Icons.check_rounded
                  : Icons.notifications_active_rounded,
              variant: state.notificationsGranted
                  ? SquircleButtonVariant.secondary
                  : SquircleButtonVariant.primary,
              expand: true,
              onPressed: state.notificationsGranted
                  ? () => ref.read(onboardingViewModelProvider.notifier).next()
                  : () => ref
                        .read(onboardingViewModelProvider.notifier)
                        .requestNotifications(),
            ),
          ),
          const Gap(CalmSpace.s2),
          if (!state.notificationsGranted)
            Semantics(
              label: LocaleKeys.onboarding_ob11_cta_skip.tr(),
              button: true,
              child: SquircleButton(
                label: LocaleKeys.onboarding_ob11_cta_skip.tr(),
                variant: SquircleButtonVariant.ghost,
                expand: true,
                onPressed: () =>
                    ref.read(onboardingViewModelProvider.notifier).next(),
              ),
            ),
        ],
      ),
    );
  }
}
