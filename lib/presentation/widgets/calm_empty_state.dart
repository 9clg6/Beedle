import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:flutter/material.dart';

/// CalmSurface §3 Empty State.
///
/// Typographique, zéro illustration générique. Option "digital" : headline
/// rendu en Doto (dot-matrix signature) pour un moment d'accent.
class CalmEmptyState extends StatelessWidget {
  const CalmEmptyState({
    required this.title,
    required this.body,
    this.digitalGlyph,
    this.cta,
    super.key,
  });

  /// Titre principal.
  final String title;

  /// Paragraphe body.md, max ~32ch idéal.
  final String body;

  /// Glyphe Doto optionnel affiché au-dessus du titre (p.ex. "000", "---").
  /// Réservé aux moments signature §2.4 Digital Display.
  final String? digitalGlyph;

  /// CTA secondaire optionnel (variant secondary.outline recommandé).
  final Widget? cta;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CalmSpace.s7,
          vertical: CalmSpace.s8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (digitalGlyph != null) ...<Widget>[
              Text(
                digitalGlyph!,
                style: AppTypography.digital(
                  const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.digital,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: CalmSpace.s7),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: CalmSpace.s4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppColors.neutral6Dark : AppColors.neutral6,
                ),
              ),
            ),
            if (cta != null) ...<Widget>[
              const SizedBox(height: CalmSpace.s7),
              cta!,
            ],
          ],
        ),
      ),
    );
  }
}
