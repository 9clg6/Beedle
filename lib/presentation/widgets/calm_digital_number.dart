import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// CalmSurface §2.4 Digital Display — affichage Doto (dot-matrix) pour
/// les moments signature : streak count, XP, logo lockup, empty state glyph.
///
/// Usage **restreint** : 1 instance par écran max. Minimum 32px pour que
/// Doto reste lisible.
class CalmDigitalNumber extends StatelessWidget {
  const CalmDigitalNumber({
    required this.value,
    this.size = 36,
    this.color,
    this.letterSpacing = 2,
    super.key,
  });

  final String value;
  final double size;
  final Color? color;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    assert(size >= 16, 'Doto illisible en dessous de 16px.');
    return Text(
      value,
      style: AppTypography.digital(
        TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: color ?? AppColors.digital,
          letterSpacing: letterSpacing,
          height: 1,
        ),
      ),
    );
  }
}
