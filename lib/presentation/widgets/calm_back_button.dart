import 'package:auto_route/auto_route.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// CalmSurface back button — cercle glass discret avec icône ink.
///
/// Haut contraste garanti sur n'importe quel fond (Aurora warm, ink, etc.).
/// Drop-in replacement pour IconButton leading.
class CalmBackButton extends StatelessWidget {
  const CalmBackButton({
    this.icon = Icons.arrow_back_ios_new_rounded,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: AppColors.glassSoft,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.neutral3),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap ?? () => context.router.maybePop(),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppColors.neutral8,
            ),
          ),
        ),
      ),
    );
  }
}

/// Variante close (X) pour les modals / paywall / import.
class CalmCloseButton extends StatelessWidget {
  const CalmCloseButton({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: AppColors.glassSoft,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.neutral3),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap ?? () => context.router.maybePop(),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.neutral8,
            ),
          ),
        ),
      ),
    );
  }
}
