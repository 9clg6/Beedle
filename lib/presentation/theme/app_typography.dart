import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typographie Beedle — CalmSurface type scale.
///
/// Stack : **Hanken Grotesk** (body/UI, anti-Inter, plus humaniste),
/// **Geist Mono** (data/chiffres), **Doto** (dot-matrix signature, usage
/// réservé aux moments accent).
///
/// Tracking convention :
/// - Display : négatif (-1% à -3%) pour compacité iOS-like
/// - Body : 0
/// - Labels : positif (+1% à +3%), uppercase autorisé sur label.sm uniquement
///
/// Weight convention : max 2 poids par écran. 400 + 600 par défaut.
abstract final class AppTypography {
  static TextStyle _hanken(TextStyle base) =>
      GoogleFonts.hankenGrotesk(textStyle: base);

  static TextStyle mono(TextStyle base) =>
      GoogleFonts.getFont('Geist Mono', textStyle: base);

  /// VT323 — pixel terminal signature. Usage RESTREINT : logo lockup, streak,
  /// empty state headline. Substitut Doto (non dispo dans google_fonts 6.3.3),
  /// très proche du "BASE44" LED orange visible sur base44.com/backend.
  static TextStyle digital(TextStyle base) =>
      GoogleFonts.vt323(textStyle: base);

  static TextTheme textTheme({required Color primary, required Color secondary}) {
    return TextTheme(
      // Display
      displayLarge: _hanken(TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -1.68, // -3%
        color: primary,
      )),
      displayMedium: _hanken(TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -1.15,
        color: primary,
      )),
      displaySmall: _hanken(TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.58,
        color: primary,
      )),

      // Headline
      headlineLarge: _hanken(TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.28,
        color: primary,
      )),
      headlineMedium: _hanken(TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.12,
        color: primary,
      )),
      headlineSmall: _hanken(TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: primary,
      )),

      // Title (iOS-like)
      titleLarge: _hanken(TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primary,
      )),
      titleMedium: _hanken(TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primary,
      )),
      titleSmall: _hanken(TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: primary,
      )),

      // Body
      bodyLarge: _hanken(TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primary,
      )),
      bodyMedium: _hanken(TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primary,
      )),
      bodySmall: _hanken(TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.45,
        letterSpacing: 0.12, // +1%
        color: secondary,
      )),

      // Labels
      labelLarge: _hanken(TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.14, // +1%
        color: primary,
      )),
      labelMedium: _hanken(TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.24, // +2%
        color: primary,
      )),
      labelSmall: _hanken(TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.25,
        letterSpacing: 0.33, // +3%, uppercase OK ici
        color: secondary,
      )),
    );
  }
}
