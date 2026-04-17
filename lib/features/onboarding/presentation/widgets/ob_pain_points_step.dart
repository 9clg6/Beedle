import 'package:beedle/domain/enum/pain_point.enum.dart';
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

/// Écran 03 — Pain points (multi-select).
///
/// 7 GlassCards à toggle. Validator gate sur `painPoints.isEmpty`.
class OnboardingPainPointsStep extends ConsumerWidget {
  const OnboardingPainPointsStep({super.key});

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
            LocaleKeys.onboarding_ob03_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s4),
          Text(
            LocaleKeys.onboarding_ob03_subtitle.tr(),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
          ),
          const Gap(CalmSpace.s7),
          for (final PainPoint p in PainPoint.values) ...<Widget>[
            _PainPointCard(
              point: p,
              selected: state.painPoints.contains(p),
              onTap: () => ref
                  .read(onboardingViewModelProvider.notifier)
                  .togglePainPoint(p),
            ),
            const Gap(CalmSpace.s3),
          ],
        ],
      ),
    );
  }
}

class _PainPointCard extends StatelessWidget {
  const _PainPointCard({
    required this.point,
    required this.selected,
    required this.onTap,
  });

  final PainPoint point;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String label = _labelKeyFor(point).tr();
    return Semantics(
      label: label,
      button: true,
      checked: selected,
      child: GlassCard(
        onTap: onTap,
        elevated: false,
        borderColor: selected ? AppColors.ink : null,
        backgroundColor: selected ? AppColors.glassMedium : null,
        padding: const EdgeInsets.symmetric(
          horizontal: CalmSpace.s5,
          vertical: CalmSpace.s4,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              selected
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: selected ? AppColors.ember : AppColors.neutral3,
              size: 22,
            ),
            const Gap(CalmSpace.s4),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelKeyFor(PainPoint p) {
    return switch (p) {
      PainPoint.pelliculeCemetery =>
        LocaleKeys.onboarding_ob03_options_pelliculeCemetery,
      PainPoint.reGoogle => LocaleKeys.onboarding_ob03_options_reGoogle,
      PainPoint.notionHeavy => LocaleKeys.onboarding_ob03_options_notionHeavy,
      PainPoint.neverRevisit => LocaleKeys.onboarding_ob03_options_neverRevisit,
      PainPoint.forgetWhatIKnow =>
        LocaleKeys.onboarding_ob03_options_forgetWhatIKnow,
      PainPoint.noTimelyReminder =>
        LocaleKeys.onboarding_ob03_options_noTimelyReminder,
      PainPoint.llmMissOut => LocaleKeys.onboarding_ob03_options_llmMissOut,
    };
  }
}
