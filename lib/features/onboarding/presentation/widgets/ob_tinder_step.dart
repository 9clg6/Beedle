import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_swipe_card.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_swipe_deck.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

const List<String> _kStatementKeys = <String>[
  LocaleKeys.onboarding_ob04_statements_s0,
  LocaleKeys.onboarding_ob04_statements_s1,
  LocaleKeys.onboarding_ob04_statements_s2,
  LocaleKeys.onboarding_ob04_statements_s3,
  LocaleKeys.onboarding_ob04_statements_s4,
];

const int _kTotalStatements = 5;

/// Écran 04 — Tinder swipe sur 5 statements.
///
/// Stack de cards Dismissible. À chaque swipe :
/// - droite → `recordTinderSwipe(idx, agreed: true)`
/// - gauche → `recordTinderSwipe(idx, agreed: false)`
///
/// Auto-advance via `next()` quand toutes les statements ont été swipées.
class OnboardingTinderStep extends ConsumerStatefulWidget {
  const OnboardingTinderStep({super.key});

  @override
  ConsumerState<OnboardingTinderStep> createState() =>
      _OnboardingTinderStepState();
}

class _OnboardingTinderStepState extends ConsumerState<OnboardingTinderStep> {
  int _currentCardIndex = 0;

  void _onDismissed(DismissDirection direction) {
    final bool agreed = direction == DismissDirection.startToEnd;
    final int swiped = _currentCardIndex;
    ref
        .read(onboardingViewModelProvider.notifier)
        .recordTinderSwipe(swiped, agreed: agreed);

    setState(() => _currentCardIndex++);

    if (_currentCardIndex >= _kTotalStatements) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(onboardingViewModelProvider.notifier).next();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

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
            LocaleKeys.onboarding_ob04_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s3),
          Text(
            LocaleKeys.onboarding_ob04_subtitle.tr(),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
          ),
          const Gap(CalmSpace.s3),
          Text(
            LocaleKeys.onboarding_ob04_progress.tr(
              namedArgs: <String, String>{
                'current': '${_currentCardIndex.clamp(0, _kTotalStatements)}',
                'total': '$_kTotalStatements',
              },
            ),
            style: textTheme.labelSmall?.copyWith(color: AppColors.neutral6),
          ),
          const Gap(CalmSpace.s5),
          Expanded(
            child: ObSwipeDeck(
              total: _kTotalStatements,
              currentIndex: _currentCardIndex,
              onDismissed: _onDismissed,
              emptyChild: const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.ember,
                  size: 48,
                ),
              ),
              cardBuilder: (BuildContext _, int idx) => OnboardingSwipeCard(
                statement: _kStatementKeys[idx].tr(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
