import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
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

const List<String> _kBulletKeys = <String>[
  LocaleKeys.onboarding_ob10_bullet0,
  LocaleKeys.onboarding_ob10_bullet1,
  LocaleKeys.onboarding_ob10_bullet2,
];

/// Écran 10 — Permission Photos primer (soft-ask + OS prompt).
///
/// Le bouton *Autoriser l'accès* déclenche `requestPhotos()` qui appelle
/// `Permission.photos.request()`. Le bouton *Plus tard* avance sans
/// permission — le state reste `photosGranted=false`.
class OnboardingPermissionPhotosStep extends ConsumerWidget {
  const OnboardingPermissionPhotosStep({super.key});

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
            value: LocaleKeys.onboarding_ob10_eyebrow.tr(),
            size: 18,
            color: AppColors.ember,
            letterSpacing: 4,
          ),
          const Gap(CalmSpace.s4),
          Text(
            LocaleKeys.onboarding_ob10_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s4),
          Text(
            LocaleKeys.onboarding_ob10_subtitle.tr(),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
          ),
          const Gap(CalmSpace.s7),
          for (final String k in _kBulletKeys) ...<Widget>[
            _Bullet(text: k.tr()),
            const Gap(CalmSpace.s3),
          ],
          const Gap(CalmSpace.s7),
          SquircleButton(
            label: LocaleKeys.onboarding_ob10_cta_allow.tr(),
            icon: state.photosGranted
                ? Icons.check_rounded
                : Icons.photo_library_rounded,
            variant: state.photosGranted
                ? SquircleButtonVariant.secondary
                : SquircleButtonVariant.primary,
            expand: true,
            onPressed: state.photosGranted
                ? () => ref.read(onboardingViewModelProvider.notifier).next()
                : () => ref
                      .read(onboardingViewModelProvider.notifier)
                      .requestPhotos(),
          ),
          const Gap(CalmSpace.s2),
          if (!state.photosGranted)
            SquircleButton(
              label: LocaleKeys.onboarding_ob10_cta_skip.tr(),
              variant: SquircleButtonVariant.ghost,
              expand: true,
              onPressed: () =>
                  ref.read(onboardingViewModelProvider.notifier).next(),
            ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Icon(
          Icons.check_circle_outline,
          color: AppColors.ember,
          size: 18,
        ),
        const Gap(CalmSpace.s3),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}
