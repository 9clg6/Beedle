import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/pill_chip.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Écran 08 — Catégories (multi-select via PillChips).
///
/// Réutilise `ContentCategory` enum existant, persiste dans
/// `state.contentCategories`. Validator gate sur `isEmpty`.
class OnboardingCategoryStep extends ConsumerWidget {
  const OnboardingCategoryStep({super.key});

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
          Text(
            LocaleKeys.onboarding_ob08_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s4),
          Text(
            LocaleKeys.onboarding_ob08_subtitle.tr(),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
          ),
          const Gap(CalmSpace.s7),
          Wrap(
            spacing: CalmSpace.s3,
            runSpacing: CalmSpace.s3,
            children: <Widget>[
              for (final ContentCategory c in ContentCategory.values)
                PillChip(
                  label: 'onboarding.ob08.options.${c.name}'.tr(),
                  selected: state.contentCategories.contains(c),
                  onTap: () => ref
                      .read(onboardingViewModelProvider.notifier)
                      .toggleCategory(c),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
