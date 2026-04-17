import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_digital_number.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Écran 01 — Welcome / Hook (full-immersion).
///
/// Hero typo + visuel statique de la Home + CTA *Commencer*. Lance
/// l'utilisateur dans le flow questionnaire — pas de NavBar visible.
class OnboardingWelcomeStep extends ConsumerWidget {
  const OnboardingWelcomeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s7,
        vertical: CalmSpace.s8,
      ),
      child: Column(
        children: <Widget>[
          const Gap(CalmSpace.s7),
          CalmDigitalNumber(
            value: LocaleKeys.onboarding_ob01_eyebrow.tr(),
            size: 18,
            color: AppColors.ember,
            letterSpacing: 4,
          ),
          const Gap(CalmSpace.s5),
          Text(
            LocaleKeys.onboarding_ob01_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              LocaleKeys.onboarding_ob01_subtitle.tr(),
              style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(CalmSpace.s8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CalmRadius.xl2),
              child: Image.asset(
                'assets/onboarding/mockup-home.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          const Gap(CalmSpace.s7),
          SquircleButton(
            label: LocaleKeys.onboarding_ob01_cta.tr(),
            icon: Icons.arrow_forward_rounded,
            expand: true,
            onPressed: () =>
                ref.read(onboardingViewModelProvider.notifier).next(),
          ),
        ],
      ),
    );
  }
}
