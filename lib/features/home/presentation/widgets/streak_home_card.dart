import 'package:beedle/domain/entities/gamification_state.entity.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_digital_number.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// CalmSurface Streak Card — gros chiffre Doto ember à gauche, métadonnées
/// alignées à droite. Signature §2.4 Digital Display.
///
/// Tap → Dashboard.
class StreakHomeCard extends StatelessWidget {
  const StreakHomeCard({
    required this.state,
    required this.onTap,
    super.key,
  });

  final GamificationStateEntity state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isActive = state.currentStreak > 0;

    return GlassCard(
      onTap: onTap,
      cornerRadius: CalmRadius.xl2,
      padding: const EdgeInsets.all(CalmSpace.s6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CalmDigitalNumber(
            value: state.currentStreak.toString().padLeft(2, '0'),
            size: 56,
            color: isActive ? AppColors.ember : AppColors.neutral4,
            letterSpacing: 3,
          ),
          const Gap(CalmSpace.s6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  LocaleKeys.home_streak_days.tr(),
                  style: AppTypography.mono(
                    const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral6,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
                const Gap(CalmSpace.s2),
                Text(
                  isActive
                      ? LocaleKeys.home_streak_active.tr()
                      : LocaleKeys.home_streak_inactive.tr(),
                  style: textTheme.titleMedium,
                ),
                if (state.longestStreak > 0) ...<Widget>[
                  const Gap(CalmSpace.s2),
                  Text(
                    LocaleKeys.home_streak_record.tr(
                      namedArgs: <String, String>{
                        'days': '${state.longestStreak}',
                      },
                    ),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral6,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.neutral4,
          ),
        ],
      ),
    );
  }
}
