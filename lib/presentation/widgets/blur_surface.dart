import 'dart:ui';

import 'package:flutter/material.dart';

/// Surface flou générique (moins opinionée que GlassCard).
/// Utile pour app bars, bottom sheets, sticky headers.
class BlurSurface extends StatelessWidget {
  const BlurSurface({
    required this.child,
    this.blurSigma = 16,
    this.tint,
    super.key,
  });

  final Widget child;
  final double blurSigma;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: ColoredBox(
        color: tint ?? Colors.white.withValues(alpha: 0.25),
        child: child,
      ),
    );
  }
}
