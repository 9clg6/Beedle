import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// CalmSurface **Aurora Frame** — halo gradient ambiant signature §2.1.
///
/// Applique `AppColors.auroraWarm` en light (cream → peach → sunset, sans
/// bleu, contrainte Beedle) et `AppColors.dusk` en dark.
///
/// Signature préservée pour backward compat. Voir `AuroraFrame` pour la
/// variante Cool (sky → cream → peach) utilisable sur autres projets.
class GradientBackground extends StatelessWidget {
  const GradientBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AuroraFrame(child: child);
  }
}

/// Aurora Frame — le pattern signature CalmSurface.
///
/// [warm] = true (défaut) utilise Aurora Warm (Beedle, zéro bleu).
/// [warm] = false utilise Aurora Cool (base44-fidèle, sky blue inclus).
class AuroraFrame extends StatelessWidget {
  const AuroraFrame({required this.child, this.warm = true, super.key});

  final Widget child;
  final bool warm;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final Gradient gradient = brightness == Brightness.dark
        ? AppColors.dusk
        : (warm ? AppColors.auroraWarm : AppColors.auroraCool);

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
