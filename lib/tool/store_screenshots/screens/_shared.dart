/// Shared primitives used across the 9 store-screenshot screens.
///
/// Not part of the production app. Lives under `lib/tool/` to keep screenshot
/// fixtures isolated from real feature code.
library;

import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// Aurora Warm canvas used as the base of most screens.
class AuroraCanvas extends StatelessWidget {
  const AuroraCanvas({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.auroraWarm),
      child: child,
    );
  }
}

/// Small Geist-mono uppercase eyebrow (e.g. "FICHE · TUTORIEL").
class CalmEyebrow extends StatelessWidget {
  const CalmEyebrow(this.text, {this.withDot = true, super.key});
  final String text;
  final bool withDot;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = AppTypography.mono(const TextStyle()).copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.1,
      color: AppColors.neutral6,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (withDot) ...<Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.ember,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: CalmSpace.s3),
        ],
        Text(text.toUpperCase(), style: style),
      ],
    );
  }
}


/// Primary solid ink CTA (pill, flat black, white text).
class InkCta extends StatelessWidget {
  const InkCta({required this.label, this.icon, this.expanded = true, super.key});
  final String label;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(cornerRadius: CalmRadius.pill),
    );
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s7,
        vertical: 14,
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 18, color: AppColors.canvas),
            const SizedBox(width: CalmSpace.s3),
          ],
          Text(
            label,
            style: AppTypography.textTheme(
              primary: AppColors.canvas,
              secondary: AppColors.canvas,
            ).labelLarge,
          ),
        ],
      ),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape, color: AppColors.ink),
      child: content,
    );
  }
}

/// Secondary outline CTA (pill, transparent, ink text, 1px border).
class OutlineCta extends StatelessWidget {
  const OutlineCta({required this.label, this.icon, this.expanded = true, super.key});
  final String label;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(cornerRadius: CalmRadius.pill),
      side: const BorderSide(color: AppColors.neutral3),
    );
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s7,
        vertical: 14,
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 18, color: AppColors.ink),
            const SizedBox(width: CalmSpace.s3),
          ],
          Text(
            label,
            style: AppTypography.textTheme(
              primary: AppColors.ink,
              secondary: AppColors.neutral6,
            ).labelLarge,
          ),
        ],
      ),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape, color: Colors.transparent),
      child: content,
    );
  }
}

/// Neutral glass pill (label + optional icon) used for metadata rows.
class GlassPill extends StatelessWidget {
  const GlassPill(this.label, {this.icon, super.key});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(cornerRadius: CalmRadius.pill),
      side: const BorderSide(color: AppColors.glassBorder),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape, color: AppColors.glassSoft),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CalmSpace.s4,
          vertical: 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 13, color: AppColors.neutral7),
              const SizedBox(width: CalmSpace.s2),
            ],
            Text(
              label,
              style: AppTypography.mono(const TextStyle()).copyWith(
                fontSize: 12,
                color: AppColors.neutral7,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Canonical liquid-glass squircle surface used for fiches, notifications, etc.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    this.radius = CalmRadius.xl2,
    this.padding = const EdgeInsets.all(CalmSpace.s6),
    this.elevated = true,
    super.key,
  });
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: radius,
        cornerSmoothing: CalmRadius.smoothingFor(radius),
      ),
      side: const BorderSide(color: AppColors.glassBorder),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        color: AppColors.glassMedium,
        shadows: elevated ? CalmShadows.lg : const <BoxShadow>[],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
