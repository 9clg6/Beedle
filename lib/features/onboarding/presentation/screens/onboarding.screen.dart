import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding_step_validator.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_goal_step.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_pain_points_step.dart';
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

/// Total d'écrans dans le flow questionnaire (0..14).
const int _kTotalScreens = 15;

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
      _ => _PlaceholderStep(index: index),
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
                  total: _kTotalScreens,
                ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    for (int i = 0; i < _kTotalScreens; i++) _buildStep(i),
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
    final bool isLast = i == _kTotalScreens - 1;
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

/// Placeholder écran — remplacé incrémentalement dans les commits suivants
/// (5 → 10) par les vrais widgets `ob_*_step.dart`.
class _PlaceholderStep extends StatelessWidget {
  const _PlaceholderStep({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CalmSpace.s7),
        child: Text(
          'Écran ${(index + 1).toString().padLeft(2, '0')} / 15',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.neutral6,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
