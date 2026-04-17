import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding_step_validator.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_category_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_comparison_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_goal_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_demo_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_pain_points_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_paywall_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_permission_notifs_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_permission_photos_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_processing_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_reminder_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_viral_moment_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_social_proof_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_solution_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_tinder_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_welcome_step.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_segmented_progress.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Source-of-truth pour le total d'écrans : `kOnboardingTotalScreens` /
// `kOnboardingLastIndex` exportés par `onboarding_step_validator.dart`.

@RoutePage()
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingViewModelProvider.notifier).finishOnboarding();
    if (mounted) {
      await context.router.replace(const HomeRoute());
    }
  }

  Widget _buildStep(int index) {
    return switch (index) {
      0 => const OnboardingWelcomeStep(),
      1 => const OnboardingGoalStep(),
      2 => const OnboardingPainPointsStep(),
      3 => const OnboardingTinderStep(),
      4 => const OnboardingSocialProofStep(),
      5 => const OnboardingSolutionStep(),
      6 => const OnboardingComparisonStep(),
      7 => const OnboardingCategoryStep(),
      8 => const OnboardingReminderStep(),
      9 => const OnboardingPermissionPhotosStep(),
      10 => const OnboardingPermissionNotifsStep(),
      11 => const OnboardingProcessingStep(),
      12 => const OnboardingDemoStep(),
      13 => const OnboardingViralMomentStep(),
      14 => const OnboardingPaywallStep(),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingState state = ref.watch(onboardingViewModelProvider);

    ref.listen(
      onboardingViewModelProvider.select((OnboardingState s) => s.currentIndex),
      (int? prev, int next) {
        if (_controller.hasClients && _controller.page?.round() != next) {
          unawaited(
            _controller.animateToPage(
              next,
              duration: CalmDuration.expressive,
              curve: CalmCurves.emphasized,
            ),
          );
        }
      },
    );

    final bool isImmersive = kFullImmersionSteps.contains(state.currentIndex);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              if (!isImmersive)
                _ProgressIndicator(
                  currentIndex: state.currentIndex,
                  total: kOnboardingTotalScreens,
                ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    for (int i = 0; i < kOnboardingTotalScreens; i++)
                      _buildStep(i),
                  ],
                ),
              ),
              if (!isImmersive) _NavBar(state: state, onFinish: _finish),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.currentIndex, required this.total});
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s6,
        CalmSpace.s5,
        CalmSpace.s6,
        0,
      ),
      child: CalmSegmentedProgress(
        currentIndex: currentIndex,
        total: total,
      ),
    );
  }
}

class _NavBar extends ConsumerWidget {
  const _NavBar({required this.state, required this.onFinish});

  final OnboardingState state;
  final Future<void> Function() onFinish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int i = state.currentIndex;
    final bool canAdvance = OnboardingStepValidator.canAdvance(i, state);
    final bool isLast = i == kOnboardingLastIndex;
    final bool isAutoAdvance = kAutoAdvanceSteps.contains(i);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s6,
        CalmSpace.s4,
        CalmSpace.s6,
        CalmSpace.s6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (!canAdvance && OnboardingStepValidator.requiresValidation(i))
            Padding(
              padding: const EdgeInsets.only(bottom: CalmSpace.s3),
              child: Text(
                _validationHintFor(i),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            children: <Widget>[
              if (i > 0)
                SquircleButton(
                  label: LocaleKeys.common_action_back.tr(),
                  variant: SquircleButtonVariant.ghost,
                  onPressed: () =>
                      ref.read(onboardingViewModelProvider.notifier).previous(),
                ),
              const Spacer(),
              if (!isAutoAdvance)
                SquircleButton(
                  label: LocaleKeys.common_action_next.tr(),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: !canAdvance
                      ? null
                      : isLast
                      ? onFinish
                      : () => ref
                            .read(onboardingViewModelProvider.notifier)
                            .next(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _validationHintFor(int index) {
    return switch (index) {
      1 => LocaleKeys.onboarding_validator_goal_required.tr(),
      2 => LocaleKeys.onboarding_validator_pain_required.tr(),
      7 => LocaleKeys.onboarding_validator_categories_required.tr(),
      12 => LocaleKeys.onboarding_validator_demo_required.tr(),
      _ => '',
    };
  }
}
