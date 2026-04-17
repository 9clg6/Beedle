import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// Variantes CalmSurface §3 Button.
///
/// - [primary]   → fill ink flat (Beedle primary). Anti-gradient, anti-glow.
/// - [mint]      → fill mint (`#DEEFA0`) pour CTA marketing/onboarding hero.
/// - [secondary] → outline 1px neutral.3, texte ink.
/// - [ghost]     → texte seul, pas de fond.
/// - [destructive] → fill danger.
enum SquircleButtonVariant { primary, mint, secondary, ghost, destructive }

/// CalmSurface Button — squircle pill, flat fill, no shadow at rest.
class SquircleButton extends StatelessWidget {
  const SquircleButton({
    required this.label,
    required this.onPressed,
    this.variant = SquircleButtonVariant.primary,
    this.icon,
    this.expand = false,
    this.loading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final SquircleButtonVariant variant;
  final IconData? icon;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final _ButtonSpec spec = _resolveSpec(variant, brightness);

    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: CalmRadius.pill,
      ),
      side: spec.borderColor != null
          ? BorderSide(color: spec.borderColor!)
          : BorderSide.none,
    );

    Widget row = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (loading)
          SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: spec.foreground,
            ),
          )
        else if (icon != null) ...<Widget>[
          Icon(icon, size: 18, color: spec.foreground),
          const SizedBox(width: CalmSpace.s3),
        ],
        if (!loading)
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(color: spec.foreground),
          ),
      ],
    );

    row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s6,
        vertical: CalmSpace.s4,
      ),
      child: row,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: shape,
        onTap: loading ? null : onPressed,
        child: AnimatedContainer(
          duration: CalmDuration.quick,
          curve: CalmCurves.standard,
          decoration: ShapeDecoration(
            shape: shape,
            color: spec.background,
            // No shadow at rest — depth via blur elsewhere.
          ),
          child: row,
        ),
      ),
    );
  }

  _ButtonSpec _resolveSpec(SquircleButtonVariant v, Brightness b) {
    final bool isDark = b == Brightness.dark;
    switch (v) {
      case SquircleButtonVariant.primary:
        return _ButtonSpec(
          foreground: isDark ? AppColors.canvasDark : AppColors.canvas,
          background: isDark ? AppColors.inkDark : AppColors.ink,
        );
      case SquircleButtonVariant.mint:
        return const _ButtonSpec(
          foreground: AppColors.ink,
          background: AppColors.mint,
        );
      case SquircleButtonVariant.secondary:
        return _ButtonSpec(
          foreground: isDark ? AppColors.neutral8Dark : AppColors.neutral8,
          background: Colors.transparent,
          borderColor: isDark ? AppColors.neutral3Dark : AppColors.neutral3,
        );
      case SquircleButtonVariant.ghost:
        return _ButtonSpec(
          foreground: isDark ? AppColors.neutral7Dark : AppColors.neutral7,
          background: Colors.transparent,
        );
      case SquircleButtonVariant.destructive:
        return const _ButtonSpec(
          foreground: Colors.white,
          background: AppColors.danger,
        );
    }
  }
}

class _ButtonSpec {
  const _ButtonSpec({
    required this.foreground,
    required this.background,
    this.borderColor,
  });

  final Color foreground;
  final Color background;
  final Color? borderColor;
}
