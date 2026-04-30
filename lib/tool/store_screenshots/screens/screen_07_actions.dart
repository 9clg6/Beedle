import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/tool/store_screenshots/screens/_shared.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// Screen 7 — From card to action: open source or continue with Claude.
class Screen07Actions extends StatelessWidget {
  const Screen07Actions({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme t = AppTypography.textTheme(
      primary: AppColors.ink,
      secondary: AppColors.neutral6,
    );
    return AuroraCanvas(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CalmSpace.s7,
                  vertical: CalmSpace.s7,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const CalmEyebrow('Fiche · Prompt'),
                    const SizedBox(height: CalmSpace.s5),
                    Text(
                      'Le prompt « Plan before code »',
                      style: t.displaySmall?.copyWith(fontSize: 30, height: 1.1),
                    ),
                    const SizedBox(height: CalmSpace.s6),
                    Text(
                      'Demande à Claude un plan détaillé AVANT toute écriture de code. Réduit les aller-retours de 60%.',
                      style: t.bodyLarge?.copyWith(height: 1.55, color: AppColors.neutral7),
                    ),
                    const Spacer(),
                    const _ActionRow(
                      icon: Icons.language,
                      title: 'Ouvrir la source',
                      subtitle: 'x.com/sama/status/…',
                    ),
                    const SizedBox(height: CalmSpace.s4),
                    const _ActionRow(
                      icon: Icons.auto_awesome_outlined,
                      title: 'Continuer avec Claude',
                      subtitle: 'Prompt pré-rempli · 1 tap',
                      emphasis: true,
                    ),
                    const SizedBox(height: CalmSpace.s4),
                    const _ActionRow(
                      icon: Icons.bookmark_outline,
                      title: 'Épingler à revoir demain',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.emphasis = false,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: CalmRadius.xl2,
        cornerSmoothing: 0.6,
      ),
      side: BorderSide(
        color: emphasis ? AppColors.glassBorderWarm : AppColors.glassBorder,
      ),
    );
    final TextTheme t = AppTypography.textTheme(
      primary: AppColors.ink,
      secondary: AppColors.neutral6,
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        color: AppColors.glassMedium,
        shadows: CalmShadows.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(CalmSpace.s5),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: emphasis
                    ? AppColors.ember.withValues(alpha: 0.12)
                    : AppColors.glassSoft,
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 20,
                color: emphasis ? AppColors.ember : AppColors.ink,
              ),
            ),
            const SizedBox(width: CalmSpace.s5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: t.titleLarge?.copyWith(fontSize: 16)),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.mono(const TextStyle()).copyWith(
                        fontSize: 12,
                        color: AppColors.neutral6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 18, color: AppColors.neutral5),
          ],
        ),
      ),
    );
  }
}
