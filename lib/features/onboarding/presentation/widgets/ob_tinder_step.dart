import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/features/onboarding/presentation/widgets/ob_swipe_card.dart';
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
            child: _CardStack(
              currentIndex: _currentCardIndex,
              onDismissed: _onDismissed,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardStack extends StatelessWidget {
  const _CardStack({
    required this.currentIndex,
    required this.onDismissed,
  });

  final int currentIndex;
  final void Function(DismissDirection) onDismissed;

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= _kTotalStatements) {
      return const Center(
        child: Icon(Icons.check_rounded, color: AppColors.ember, size: 48),
      );
    }

    // Affiche la top card swipable + les 2 prochaines en background pour
    // l'effet visuel "deck".
    final List<Widget> cards = <Widget>[];
    final int maxBackground = (_kTotalStatements - currentIndex - 1).clamp(
      0,
      2,
    );
    for (int i = maxBackground; i >= 1; i--) {
      cards.add(
        Positioned.fill(
          top: i * 8.0,
          left: i * 6.0,
          right: i * 6.0,
          child: Opacity(
            opacity: 1.0 - (i * 0.18),
            child: OnboardingSwipeCard(
              statement: _kStatementKeys[currentIndex + i].tr(),
            ),
          ),
        ),
      );
    }
    cards.add(
      Positioned.fill(
        child: Dismissible(
          key: ValueKey<int>(currentIndex),
          direction: DismissDirection.horizontal,
          onDismissed: onDismissed,
          child: OnboardingSwipeCard(
            statement: _kStatementKeys[currentIndex].tr(),
          ),
        ),
      ),
    );
    return Stack(children: cards);
  }
}
