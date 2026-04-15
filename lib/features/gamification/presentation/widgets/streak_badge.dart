import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Compact streak badge à afficher en header home.
class StreakBadge extends StatelessWidget {
  const StreakBadge({required this.streak, this.onTap, super.key});

  final int streak;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (streak == 0) return const SizedBox.shrink();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 0.6),
          ),
          gradient: AppColors.teaserGradient,
          shadows: <BoxShadow>[
            BoxShadow(
              color: AppColors.flame.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 16),
            const Gap(4),
            Text(
              '$streak',
              style: textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
