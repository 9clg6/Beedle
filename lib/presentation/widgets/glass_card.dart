import 'dart:ui';

import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// CalmSurface Liquid Glass Card.
///
/// Defaults : radius 28, cornerSmoothing 0.6, blur σ 20, glass.medium,
/// border 1px glass.border, shadow.lg (6% max).
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(CalmSpace.s6),
    this.cornerRadius = CalmRadius.xl2,
    this.cornerSmoothing = 0.6,
    this.blurSigma = 12,
    this.onTap,
    this.elevated = true,
    this.gradient,
    this.borderColor,
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double cornerRadius;
  final double cornerSmoothing;
  final double blurSigma;
  final VoidCallback? onTap;
  final bool elevated;
  final Gradient? gradient;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color resolvedBg =
        backgroundColor ??
        (brightness == Brightness.dark
            ? AppColors.glassDarkMedium
            : AppColors.glassMedium);
    final Color resolvedBorder =
        borderColor ??
        (brightness == Brightness.dark
            ? AppColors.glassDarkBorder
            : AppColors.glassBorder);

    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: cornerRadius,
        cornerSmoothing: cornerSmoothing,
      ),
      side: BorderSide(color: resolvedBorder),
    );

    final ShapeBorderClipper clipper = ShapeBorderClipper(shape: shape);

    Widget content = Padding(padding: padding, child: child);

    content = ClipPath(
      clipper: clipper,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: ShapeDecoration(
            shape: shape,
            color: gradient == null ? resolvedBg : null,
            gradient: gradient,
            shadows: elevated ? CalmShadows.lg : const <BoxShadow>[],
          ),
          child: content,
        ),
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
