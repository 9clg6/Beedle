import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

const List<String> _kBeforeKeys = <String>[
  LocaleKeys.onboarding_ob07_before_items_i0,
  LocaleKeys.onboarding_ob07_before_items_i1,
  LocaleKeys.onboarding_ob07_before_items_i2,
  LocaleKeys.onboarding_ob07_before_items_i3,
];

const List<String> _kAfterKeys = <String>[
  LocaleKeys.onboarding_ob07_after_items_i0,
  LocaleKeys.onboarding_ob07_after_items_i1,
  LocaleKeys.onboarding_ob07_after_items_i2,
  LocaleKeys.onboarding_ob07_after_items_i3,
];

/// Écran 07 — Avant/Après (deux GlassCards verticales).
class OnboardingComparisonStep extends StatelessWidget {
  const OnboardingComparisonStep({super.key});

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
            LocaleKeys.onboarding_ob07_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s7),
          _ComparisonCard(
            title: LocaleKeys.onboarding_ob07_before_title.tr(),
            items: _kBeforeKeys.map((String k) => k.tr()).toList(),
            iconColor: AppColors.neutral6,
            icon: Icons.close_rounded,
          ),
          const Gap(CalmSpace.s4),
          _ComparisonCard(
            title: LocaleKeys.onboarding_ob07_after_title.tr(),
            items: _kAfterKeys.map((String k) => k.tr()).toList(),
            iconColor: AppColors.ember,
            icon: Icons.check_rounded,
          ),
        ],
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.title,
    required this.items,
    required this.iconColor,
    required this.icon,
  });

  final String title;
  final List<String> items;
  final Color iconColor;
  final IconData icon;

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
            title,
            style: textTheme.titleMedium?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s4),
          for (final String item in items) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, color: iconColor, size: 18),
                const Gap(CalmSpace.s3),
                Expanded(
                  child: Text(
                    item,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral8,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(CalmSpace.s2),
          ],
        ],
      ),
    );
  }
}
