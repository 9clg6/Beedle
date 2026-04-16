import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Variante de rendu de l'icône Beedle.
enum BeedleIconVariant {
  /// Lumineux, usage par défaut : fond Aurora warm, `b` ink, point ember.
  light,

  /// Fond ink pour contexte sombre / mode Dark : `b` canvas, point ember.
  dark,

  /// Monochrome, un seul ton (ex: notification icon Android tinté par l'OS,
  /// silhouette en avatar). Tout est rendu dans la même couleur tirée du
  /// paramètre `monochromeColor`.
  monochrome,
}

/// L'app icon Beedle "Dot-b" — `b` italicisé ink + point ember sur un
/// squircle Aurora warm.
///
/// Rendu natif Flutter via `figma_squircle` (vrai squircle iOS, pas un
/// rounded rect). Toutes les dimensions sont normalisées en fraction de
/// [size] pour que le widget soit net à n'importe quelle taille (16, 60,
/// 180, 1024…).
///
/// Usage typique :
/// ```dart
/// const BeedleIconAsset(size: 96)              // splash / about
/// BeedleIconAsset(size: 64, elevated: false)    // avatar compact
/// BeedleIconAsset(
///   size: 48,
///   variant: BeedleIconVariant.monochrome,
///   monochromeColor: Colors.white,
/// )
/// ```
///
/// Pour exporter en PNG (pour les stores), utiliser `RepaintBoundary` +
/// `toImage()` via un script `tool/render_icon.dart`.
class BeedleIconAsset extends StatelessWidget {
  const BeedleIconAsset({
    this.size = 96,
    this.variant = BeedleIconVariant.light,
    this.monochromeColor,
    this.elevated = true,
    super.key,
  }) : assert(
         variant != BeedleIconVariant.monochrome || monochromeColor != null,
         'monochromeColor must be provided when variant is monochrome',
       );

  /// Taille d'arête du squircle en pixels logiques. Tout le contenu scale
  /// proportionnellement.
  final double size;

  /// Variante visuelle (light / dark / monochrome).
  final BeedleIconVariant variant;

  /// Couleur unique pour la variante [BeedleIconVariant.monochrome].
  final Color? monochromeColor;

  /// Applique une ombre douce 6% sous le squircle. Désactiver en usage
  /// avatar compact ou en overlay.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    // Proportions normalisées sur un canvas 1024 → fractions appliquées à
    // `size` pour un rendu net à toutes les échelles.
    const double baseCanvas = 1024;
    final double scale = size / baseCanvas;

    final double radius = 225 * scale; // ~22% corner radius
    final double letterFontSize = 560 * scale;
    final double dotRadius = 36 * scale;
    final double dotCx = 520 * scale;
    final double dotCy = 165 * scale;

    final _BeedleIconPalette palette = _paletteFor(variant, monochromeColor);

    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: radius,
        cornerSmoothing: 0.6,
      ),
    );

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          color: palette.background,
          gradient: palette.gradient,
          shadows: elevated
              ? <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF1C1C19).withValues(alpha: 0.08),
                    offset: Offset(0, 24 * scale),
                    blurRadius: 48 * scale,
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: ClipPath(
          clipper: ShapeBorderClipper(shape: shape),
          child: Stack(
            children: <Widget>[
              // Letter 'b' — italicized 8° via Matrix4 skewX.
              Positioned.fill(
                child: Align(
                  child: Transform(
                    transform: Matrix4.skewX(-0.14), // ~8° left shear
                    alignment: Alignment.center,
                    child: Text(
                      'b',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.hankenGrotesk(
                        textStyle: TextStyle(
                          fontSize: letterFontSize,
                          fontWeight: FontWeight.w700,
                          color: palette.letter,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Ember dot above the ascender — the "ping back" signal.
              Positioned(
                left: dotCx - dotRadius,
                top: dotCy - dotRadius,
                width: dotRadius * 2,
                height: dotRadius * 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.dot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // The Transform above approximates italic skewX(-8deg). Using Matrix4.skewX
    // with tan(8°) ≈ 0.1405 — we use 0.14 as a slightly cleaner value. A true
    // oblique render would use `fontStyle: FontStyle.italic` on Hanken Grotesk,
    // but Hanken Grotesk's native italic has its own design which differs
    // slightly from a pure oblique; the skew approach matches the design spec
    // (§docs/brainstorming-app-icon-2026-04-16.md).
  }

  _BeedleIconPalette _paletteFor(
    BeedleIconVariant v,
    Color? monochromeColor,
  ) {
    switch (v) {
      case BeedleIconVariant.light:
        return const _BeedleIconPalette(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: <double>[0, 0.4, 0.75, 1],
            colors: <Color>[
              Color(0xFFFFFBF5),
              Color(0xFFFFE9D0),
              Color(0xFFFFDBB0),
              Color(0xFFFFC48A),
            ],
          ),
          letter: AppColors.ink,
          dot: AppColors.ember,
        );
      case BeedleIconVariant.dark:
        return const _BeedleIconPalette(
          background: AppColors.ink,
          letter: AppColors.canvas,
          dot: AppColors.ember,
        );
      case BeedleIconVariant.monochrome:
        final Color tint = monochromeColor!;
        return _BeedleIconPalette(
          background: Colors.transparent,
          letter: tint,
          dot: tint,
        );
    }
  }
}

/// Résolu à l'exécution selon la variante — regroupe les 3 couleurs clés.
class _BeedleIconPalette {
  const _BeedleIconPalette({
    required this.letter,
    required this.dot,
    this.background,
    this.gradient,
  });

  final Color? background;
  final Gradient? gradient;
  final Color letter;
  final Color dot;
}
