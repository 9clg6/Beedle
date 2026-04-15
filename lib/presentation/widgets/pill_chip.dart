import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// CalmSurface §3 Pill / Chip.
///
/// Inactif : fill glass.soft, border 1px glass.border, texte ink.
/// Actif : fill ink flat, texte canvas. Zéro gradient sur l'actif.
/// (Le paramètre [gradient] reste accepté pour retro-compat mais est ignoré
/// hors cas exceptionnel où il représente un accent branded.)
class PillChip extends StatelessWidget {
  const PillChip({
    required this.label,
    this.icon,
    this.onTap,
    this.selected = false,
    this.gradient,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool selected;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final foreground = selected
        ? (isDark ? AppColors.canvasDark : AppColors.canvas)
        : (isDark ? AppColors.neutral8Dark : AppColors.neutral8);

    final background = selected
        ? (isDark ? AppColors.inkDark : AppColors.ink)
        : (isDark ? AppColors.glassDarkSoft : AppColors.glassSoft);

    final borderColor = selected
        ? Colors.transparent
        : (isDark ? AppColors.glassDarkBorder : AppColors.neutral3);

    final shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: CalmRadius.pill,
      ),
      side: BorderSide(color: borderColor),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: AnimatedContainer(
          duration: CalmDuration.quick,
          curve: CalmCurves.standard,
          padding: const EdgeInsets.symmetric(
            horizontal: CalmSpace.s4,
            vertical: CalmSpace.s3,
          ),
          decoration: ShapeDecoration(
            shape: shape,
            color: gradient == null ? background : null,
            gradient: selected ? gradient : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 14, color: foreground),
                const SizedBox(width: CalmSpace.s2),
              ],
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
