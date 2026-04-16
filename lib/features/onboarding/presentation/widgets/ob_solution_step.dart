import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

const List<({String painKey, String fixKey})> _kPairs =
    <({String painKey, String fixKey})>[
      (
        painKey: LocaleKeys.onboarding_ob06_items_i0_pain,
        fixKey: LocaleKeys.onboarding_ob06_items_i0_fix,
      ),
      (
        painKey: LocaleKeys.onboarding_ob06_items_i1_pain,
        fixKey: LocaleKeys.onboarding_ob06_items_i1_fix,
      ),
      (
        painKey: LocaleKeys.onboarding_ob06_items_i2_pain,
        fixKey: LocaleKeys.onboarding_ob06_items_i2_fix,
      ),
      (
        painKey: LocaleKeys.onboarding_ob06_items_i3_pain,
        fixKey: LocaleKeys.onboarding_ob06_items_i3_fix,
      ),
    ];

/// Écran 06 — Solution (4 paires pain → fix avec icône ember).
class OnboardingSolutionStep extends StatelessWidget {
  const OnboardingSolutionStep({super.key});

  @override
  Widget build(BuildContext context) {
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
            LocaleKeys.onboarding_ob06_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s7),
          for (final ({String painKey, String fixKey}) p
              in _kPairs) ...<Widget>[
            _PainFixCard(pain: p.painKey.tr(), fix: p.fixKey.tr()),
            const Gap(CalmSpace.s4),
          ],
        ],
      ),
    );
  }
}

class _PainFixCard extends StatelessWidget {
  const _PainFixCard({required this.pain, required this.fix});

  final String pain;
  final String fix;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return GlassCard(
      elevated: false,
      padding: const EdgeInsets.all(CalmSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            pain,
            style: textTheme.titleSmall?.copyWith(color: AppColors.neutral6),
          ),
          const Gap(CalmSpace.s2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.ember,
                size: 18,
              ),
              const Gap(CalmSpace.s3),
              Expanded(
                child: Text(
                  fix,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.ink),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
