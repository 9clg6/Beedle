/// CalmSurface design tokens — source of truth for colors, radius, space,
/// motion. Voir `docs/DESIGN.md` pour la spec complète.
///
/// Les classes existantes (AppColors, AppTypography) consomment ces tokens.
/// Ne JAMAIS utiliser de valeurs magiques dans les widgets : tout passe par ici.
library;

import 'package:flutter/material.dart';

// ────────────────────────────────────────────────────────────────────
// Radius & Shape (squircle)
// ────────────────────────────────────────────────────────────────────

abstract final class CalmRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 28;
  static const double xl3 = 40;
  static const double pill = 999;

  /// Règle "plus grand = plus smooth". Paire chaque radius avec son
  /// `cornerSmoothing` recommandé pour figma_squircle.
  static double smoothingFor(double r) {
    if (r <= 8) return 0;
    if (r <= 16) return 0.5;
    if (r <= 28) return 0.6;
    if (r <= 40) return 0.7;
    return 0.8;
  }
}

// ────────────────────────────────────────────────────────────────────
// Space scale (4pt based)
// ────────────────────────────────────────────────────────────────────

abstract final class CalmSpace {
  static const double s0 = 0;
  static const double s1 = 2;
  static const double s2 = 4;
  static const double s3 = 8;
  static const double s4 = 12;
  static const double s5 = 16;
  static const double s6 = 20;
  static const double s7 = 24;
  static const double s8 = 32;
  static const double s9 = 40;
  static const double s10 = 56;
  static const double s11 = 72;
  static const double s12 = 96;
}

// ────────────────────────────────────────────────────────────────────
// Motion — durées & courbes
// ────────────────────────────────────────────────────────────────────

abstract final class CalmDuration {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration quick = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 240);
  static const Duration expressive = Duration(milliseconds: 400);
  static const Duration grand = Duration(milliseconds: 640);
}

abstract final class CalmCurves {
  /// Transitions expressives (page reveal, stagger parent).
  static const Cubic emphasized = Cubic(0.3, 0, 0, 1);

  /// État standard (press, fade).
  static const Cubic standard = Cubic(0.2, 0, 0, 1);

  /// Doux (glass ops, scrim).
  static const Cubic soft = Cubic(0.4, 0, 0.2, 1);
}

// ────────────────────────────────────────────────────────────────────
// Elevation — shadows très discrets
// ────────────────────────────────────────────────────────────────────

abstract final class CalmShadows {
  /// Whisper-level shadow. Max opacity 6%. Profondeur vient du blur + border.
  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A000000), // 4%
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(
      color: Color(0x0D000000), // 5%
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> lg = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F000000), // 6%
      blurRadius: 64,
      offset: Offset(0, 24),
    ),
  ];
}

// ────────────────────────────────────────────────────────────────────
// Blur sigmas par layer
// ────────────────────────────────────────────────────────────────────

abstract final class CalmBlur {
  static const double surface = 8;
  static const double floating = 16;
  static const double overlay = 24;
  static const double modal = 40;
}
