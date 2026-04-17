import 'package:beedle/domain/enum/onboarding_goal.enum.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Écran 02 — Goal (single-select).
///
/// 6 GlassCards verticales, sélection unique. Le NavBar grise
/// *Continuer* tant que `state.goal == null`.
class OnboardingGoalStep extends ConsumerWidget {
  const OnboardingGoalStep({super.key});

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
            LocaleKeys.onboarding_ob02_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s4),
          Text(
            LocaleKeys.onboarding_ob02_subtitle.tr(),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
          ),
          const Gap(CalmSpace.s7),
          for (final OnboardingGoal goal in OnboardingGoal.values) ...<Widget>[
            _GoalOptionCard(
              goal: goal,
              selected: state.goal == goal,
              onTap: () => ref
                  .read(onboardingViewModelProvider.notifier)
                  .selectGoal(goal),
            ),
            const Gap(CalmSpace.s3),
          ],
        ],
      ),
    );
  }
}

class _GoalOptionCard extends StatelessWidget {
  const _GoalOptionCard({
    required this.goal,
    required this.selected,
    required this.onTap,
  });

  final OnboardingGoal goal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String label = _labelKeyFor(goal).tr();
    return Semantics(
      label: label,
      button: true,
      selected: selected,
      child: GlassCard(
        onTap: onTap,
        elevated: false,
        borderColor: selected ? AppColors.ink : null,
        backgroundColor: selected ? AppColors.glassMedium : null,
        padding: const EdgeInsets.symmetric(
          horizontal: CalmSpace.s5,
          vertical: CalmSpace.s5,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: textTheme.titleMedium?.copyWith(color: AppColors.ink),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.ember, size: 22)
            else
              const Icon(
                Icons.circle_outlined,
                color: AppColors.neutral3,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  String _labelKeyFor(OnboardingGoal goal) {
    return switch (goal) {
      OnboardingGoal.buildFaster =>
        LocaleKeys.onboarding_ob02_options_buildFaster,
      OnboardingGoal.stayAIUpToDate =>
        LocaleKeys.onboarding_ob02_options_stayAIUpToDate,
      OnboardingGoal.rememberTutorials =>
        LocaleKeys.onboarding_ob02_options_rememberTutorials,
      OnboardingGoal.findInfoFast =>
        LocaleKeys.onboarding_ob02_options_findInfoFast,
      OnboardingGoal.shareWithTeam =>
        LocaleKeys.onboarding_ob02_options_shareWithTeam,
      OnboardingGoal.exploring => LocaleKeys.onboarding_ob02_options_exploring,
    };
  }
}
