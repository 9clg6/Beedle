import 'package:flutter/material.dart';

/// Palette Beedle — **CalmSurface design system**, variante Warm (zéro bleu).
///
/// Fusion Apple Liquid Glass / Base44 / Raycast / Nothing. Gradient Aurora
/// (cream → peach → sunset), surfaces glass blur, accents ember & digital.
/// Voir `docs/DESIGN.md` pour la spec complète.
///
/// Compat : les anciens tokens (orange500, primaryGradient, glassMedium, etc.)
/// sont conservés en alias pour éviter de casser les call sites existants.
abstract final class AppColors {
  // ──────────────────────────────────────────────────────────────────
  // Neutres — Light (cool-warm, bias cream)
  // ──────────────────────────────────────────────────────────────────
  static const Color canvas = Color(0xFFFBF8F3);
  static const Color surface = Color(0xFFF8F4ED);
  static const Color neutral2 = Color(0xFFEFE9E0);
  static const Color neutral3 = Color(0xFFE2DBCE);
  static const Color neutral4 = Color(0xFFC9C1B3);
  static const Color neutral5 = Color(0xFF9A9286);
  static const Color neutral6 = Color(0xFF6C645A);
  static const Color neutral7 = Color(0xFF433C33);
  static const Color neutral8 = Color(0xFF1F1A13);
  static const Color ink = Color(0xFF0A0A0A);

  // ──────────────────────────────────────────────────────────────────
  // Neutres — Dark (dusk chaud, jamais noir pur)
  // ──────────────────────────────────────────────────────────────────
  static const Color canvasDark = Color(0xFF140C05);
  static const Color surfaceDark = Color(0xFF1E1610);
  static const Color neutral2Dark = Color(0xFF261B10);
  static const Color neutral3Dark = Color(0xFF2E2318);
  static const Color neutral4Dark = Color(0xFF4A3F33);
  static const Color neutral5Dark = Color(0xFF7A6D5E);
  static const Color neutral6Dark = Color(0xFFA69684);
  static const Color neutral7Dark = Color(0xFFD6BEA0);
  static const Color neutral8Dark = Color(0xFFF0E3D0);
  static const Color inkDark = Color(0xFFFFF3E1);

  // ──────────────────────────────────────────────────────────────────
  // Accents — uniquement 3, réservés
  // ──────────────────────────────────────────────────────────────────
  /// Anti-purple. Pale lime-green inspirée Base44 CTA.
  static const Color mint = Color(0xFFDEEFA0);

  /// Ember orange, brand Beedle.
  static const Color ember = Color(0xFFFF6B2E);

  /// Même teinte qu'ember, mais usage réservé à la Doto (LED-signature).
  static const Color digital = Color(0xFFFF6B2E);

  // ──────────────────────────────────────────────────────────────────
  // Glass tints (Liquid Glass iOS 26)
  // ──────────────────────────────────────────────────────────────────
  static const Color glassStrong = Color(0xEBFFFFFF); // 92%
  static const Color glassMedium = Color(0xD9FFFFFF); // 85%
  static const Color glassSoft = Color(0xB3FFFFFF); // 70%
  static const Color glassBorder = Color(0x33FFFFFF); // 20%
  static const Color glassBorderWarm = Color(0x29EA580C); // 16% ember

  static const Color glassDarkStrong = Color(0xF01F170E); // 94%
  static const Color glassDarkMedium = Color(0xCC261B10); // 80%
  static const Color glassDarkSoft = Color(0x992D2014); // 60%
  static const Color glassDarkBorder = Color(0x33FFD9AE); // 20% warm

  // ──────────────────────────────────────────────────────────────────
  // Semantic — l'icône porte le sens, la surface reste neutre
  // ──────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color error = danger; // alias compat

  // ──────────────────────────────────────────────────────────────────
  // Gradients nommés
  // ──────────────────────────────────────────────────────────────────

  /// Aurora Warm — halo signature Beedle, vertical, sans bleu.
  /// Cream → peach → sunset.
  static const LinearGradient auroraWarm = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: <double>[0, 0.4, 0.75, 1],
    colors: <Color>[
      Color(0xFFFFFBF5),
      Color(0xFFFFE9D0),
      Color(0xFFFFDBB0),
      Color(0xFFFFC48A),
    ],
  );

  /// Aurora Cool — variante base44-fidèle. Sky → cream → peach.
  /// Utilisée sur autres projets où le bleu est autorisé.
  static const LinearGradient auroraCool = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: <double>[0, 0.5, 1],
    colors: <Color>[
      Color(0xFFC5E0EE),
      Color(0xFFE8E4DE),
      Color(0xFFFFE0C2),
    ],
  );

  /// Ember — gradient radial orange feu pour feature cards accent.
  /// Usage MAXIMUM une fois par écran.
  static const RadialGradient emberMesh = RadialGradient(
    center: Alignment(-0.4, -0.2),
    radius: 1.2,
    colors: <Color>[
      Color(0xFFFF5A1F),
      Color(0xFFFF8C42),
      Color(0xFFFFB067),
      Color(0x00FFB067),
    ],
    stops: <double>[0, 0.4, 0.8, 1],
  );

  /// Dusk — dark hero, jamais noir pur.
  static const LinearGradient dusk = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFF241810),
      Color(0xFF2E1F11),
      Color(0xFF140C05),
    ],
  );

  /// Mist — cool secondary, pour surfaces sans chaleur.
  static const LinearGradient mist = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFFF0F2F4),
      Color(0xFFDDE2E7),
    ],
  );

  // ──────────────────────────────────────────────────────────────────
  // ALIASES — compat avec l'ancienne API (ne pas casser les call sites).
  // À migrer progressivement.
  // ──────────────────────────────────────────────────────────────────
  @Deprecated('Use canvas')
  static const Color cream50 = canvas;
  @Deprecated('Use surface')
  static const Color cream100 = surface;
  @Deprecated('Use neutral2')
  static const Color cream200 = neutral2;
  static const Color peach100 = Color(0xFFFFE1C4);
  static const Color peach200 = Color(0xFFFFCFA1);
  static const Color peach300 = Color(0xFFFFB877);

  @Deprecated('Use ember')
  static const Color orange300 = Color(0xFFFDA54A);
  @Deprecated('Use ember')
  static const Color orange400 = Color(0xFFFB923C);
  @Deprecated('Use ember')
  static const Color orange500 = ember;
  @Deprecated('Use ember')
  static const Color orange600 = Color(0xFFEA580C);

  @Deprecated('Use ember')
  static const Color flame = ember;
  @Deprecated('Use warning')
  static const Color amber = warning;

  @Deprecated('Use glassStrong')
  static const Color glassLight = glassStrong;

  @Deprecated('Use neutral8')
  static const Color textPrimaryLight = neutral8;
  @Deprecated('Use neutral6')
  static const Color textSecondaryLight = neutral6;
  @Deprecated('Use neutral8Dark')
  static const Color textPrimaryDark = neutral8Dark;
  @Deprecated('Use neutral6Dark')
  static const Color textSecondaryDark = neutral6Dark;

  @Deprecated('Use canvas')
  static const Color backgroundLight = canvas;
  @Deprecated('Use canvasDark')
  static const Color backgroundDark = canvasDark;

  /// Ancien "background gradient" → remappé sur Aurora Warm.
  static const LinearGradient backgroundGradientLight = auroraWarm;
  static const LinearGradient backgroundGradientDark = dusk;

  /// Ancien "primary gradient" (boutons) → CalmSurface utilise ink flat,
  /// mais on conserve le gradient ember pour les moments accent (badges,
  /// streak, hero highlight) où il reste pertinent.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFFF8C42), ember],
  );

  /// Ancien "teaser gradient".
  static const LinearGradient teaserGradient = LinearGradient(
    colors: <Color>[warning, ember],
  );
}
