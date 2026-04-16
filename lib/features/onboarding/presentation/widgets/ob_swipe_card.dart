import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:flutter/material.dart';

/// Carte interne du stack Tinder (écran 04).
///
/// Affiche une statement centrée + deux indicateurs de swipe direction
/// (✗ gauche, ✓ droite) en pied de carte. Visuel statique — la mécanique
/// `Dismissible` est gérée par le parent `OnboardingTinderStep`.
class OnboardingSwipeCard extends StatelessWidget {
  const OnboardingSwipeCard({required this.statement, super.key});

  final String statement;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return GlassCard(
      padding: const EdgeInsets.all(CalmSpace.s7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Spacer(),
          Text(
            statement,
            style: textTheme.headlineSmall?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _SwipeHint(
                icon: Icons.close_rounded,
                color: AppColors.neutral6,
              ),
              _SwipeHint(
                icon: Icons.check_rounded,
                color: AppColors.ember,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CalmSpace.s3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
