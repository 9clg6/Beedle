import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:flutter/material.dart';

enum CalmBadgeVariant { neutral, ember, digital, mint }

/// CalmSurface §3 Badge — pill 20px, usage métadata.
class CalmBadge extends StatelessWidget {
  const CalmBadge({
    required this.label,
    this.variant = CalmBadgeVariant.neutral,
    this.icon,
    super.key,
  });

  final String label;
  final CalmBadgeVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final _BadgeSpec spec = _resolveSpec(variant, isDark);
    final TextStyle? baseStyle = textTheme.labelSmall?.copyWith(
      color: spec.foreground,
      fontWeight: FontWeight.w600,
    );
    final TextStyle? style = variant == CalmBadgeVariant.digital
        ? AppTypography.digital(baseStyle ?? const TextStyle())
        : baseStyle;

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s3,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: spec.background,
        borderRadius: BorderRadius.circular(CalmRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12, color: spec.foreground),
            const SizedBox(width: CalmSpace.s2),
          ],
          Text(label, style: style),
        ],
      ),
    );
  }

  _BadgeSpec _resolveSpec(CalmBadgeVariant v, bool isDark) {
    switch (v) {
      case CalmBadgeVariant.neutral:
        return _BadgeSpec(
          foreground: isDark ? AppColors.neutral8Dark : AppColors.neutral8,
          background: isDark ? AppColors.neutral2Dark : AppColors.neutral2,
        );
      case CalmBadgeVariant.ember:
        return const _BadgeSpec(
          foreground: Colors.white,
          background: AppColors.ember,
        );
      case CalmBadgeVariant.digital:
        return const _BadgeSpec(
          foreground: AppColors.digital,
          background: Color(0x0AFF6B2E), // 4% ember
        );
      case CalmBadgeVariant.mint:
        return const _BadgeSpec(
          foreground: AppColors.ink,
          background: AppColors.mint,
        );
    }
  }
}

class _BadgeSpec {
  const _BadgeSpec({required this.foreground, required this.background});
  final Color foreground;
  final Color background;
}
