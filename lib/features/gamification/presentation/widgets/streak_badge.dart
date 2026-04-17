import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:flutter/material.dart';

/// CalmSurface streak badge — flat, zéro glow, pas de gradient.
///
/// Pattern §2.4 Digital Display : chiffre en Doto ember sur fond 4% ember,
/// icône flamme discrète. Anti-glassmorphism-2021.
class StreakBadge extends StatelessWidget {
  const StreakBadge({required this.streak, this.onTap, super.key});

  final int streak;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CalmRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CalmSpace.s3,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0x0AFF6B2E), // ember 4%
            borderRadius: BorderRadius.circular(CalmRadius.pill),
            border: Border.all(
              color: const Color(0x29FF6B2E), // ember 16%
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.local_fire_department_rounded,
                size: 14,
                color: AppColors.ember,
              ),
              const SizedBox(width: CalmSpace.s2),
              Text(
                streak.toString().padLeft(2, '0'),
                style: AppTypography.digital(
                  const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ember,
                    letterSpacing: 1.5,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
