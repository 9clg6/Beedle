import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/features/onboarding/presentation/widgets/demo_sample_card.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_swipe_deck.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// 5 samples — l'index correspond à `assets/onboarding/samples/cards.json`.
const List<({String asset, String title})> _kSamples =
    <({String asset, String title})>[
      (
        asset: 'assets/onboarding/samples/sample-prompt-eval.png',
        title: 'Évalue n\'importe quel LLM en 30 secondes',
      ),
      (
        asset: 'assets/onboarding/samples/sample-claude-code-skills.png',
        title: 'Claude Code Skills, mode d\'emploi',
      ),
      (
        asset: 'assets/onboarding/samples/sample-figma-autolayout.png',
        title: 'Figma Auto-layout : le pattern qui change tout',
      ),
      (
        asset: 'assets/onboarding/samples/sample-dart-async.png',
        title: 'Dart async : isolate vs compute()',
      ),
      (
        asset: 'assets/onboarding/samples/sample-raycast-cmd.png',
        title: 'Raycast : 5 commandes que tu utiliseras tous les jours',
      ),
    ];

/// Écran 13 — Demo (5 sample cards à swipe-keep).
///
/// Validator gate : `demoSwipedRightIndices.length >= 3`. L'utilisateur
/// peut swipe les 5, le NavBar débloque *Continuer* dès le 3e gardé.
class OnboardingDemoStep extends ConsumerStatefulWidget {
  const OnboardingDemoStep({super.key});

  @override
  ConsumerState<OnboardingDemoStep> createState() => _OnboardingDemoStepState();
}

class _OnboardingDemoStepState extends ConsumerState<OnboardingDemoStep> {
  int _currentCardIndex = 0;

  void _onDismissed(DismissDirection direction) {
    final bool keep = direction == DismissDirection.startToEnd;
    final int swiped = _currentCardIndex;
    ref
        .read(onboardingViewModelProvider.notifier)
        .recordDemoSwipe(swiped, keep: keep);
    setState(() => _currentCardIndex++);
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingState state = ref.watch(onboardingViewModelProvider);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int kept = state.demoSwipedRightIndices.length;

    return Padding(
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
            LocaleKeys.onboarding_ob13_title.tr(),
            style: textTheme.headlineMedium?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s3),
          Text(
            LocaleKeys.onboarding_ob13_subtitle.tr(),
            style: textTheme.bodyMedium?.copyWith(color: AppColors.neutral6),
          ),
          const Gap(CalmSpace.s3),
          Text(
            LocaleKeys.onboarding_ob13_progress.tr(
              namedArgs: <String, String>{'kept': '$kept'},
            ),
            style: textTheme.labelSmall?.copyWith(color: AppColors.ember),
          ),
          const Gap(CalmSpace.s5),
          Expanded(
            child: ObSwipeDeck(
              total: _kSamples.length,
              currentIndex: _currentCardIndex,
              onDismissed: _onDismissed,
              emptyChild: Center(
                child: Padding(
                  padding: const EdgeInsets.all(CalmSpace.s7),
                  child: Text(
                    'Toutes les cards ont été passées en revue.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              cardBuilder: (BuildContext _, int idx) => DemoSampleCard(
                assetPath: _kSamples[idx].asset,
                title: _kSamples[idx].title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
