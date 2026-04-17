import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:flutter/material.dart';

/// CalmSurface §3 Progress — variante "segmented" Nothing-style.
///
/// Row de pills 4×12px, gap 2px. Active = ink flat, inactive = neutral.2.
/// Zéro dégradé, zéro bar continue.
class CalmSegmentedProgress extends StatelessWidget {
  const CalmSegmentedProgress({
    required this.currentIndex,
    required this.total,
    this.segmentHeight = 4,
    this.gap = 4,
    super.key,
  });

  final int currentIndex;
  final int total;
  final double segmentHeight;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = isDark ? AppColors.inkDark : AppColors.ink;
    final Color inactiveColor = isDark
        ? AppColors.neutral3Dark
        : AppColors.neutral2;

    return SizedBox(
      height: segmentHeight,
      child: Row(
        children: List<Widget>.generate(total, (int i) {
          final bool active = i <= currentIndex;
          final bool isLast = i == total - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : gap),
              child: AnimatedContainer(
                duration: CalmDuration.standard,
                curve: CalmCurves.standard,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(CalmRadius.pill),
                  color: active ? activeColor : inactiveColor,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
