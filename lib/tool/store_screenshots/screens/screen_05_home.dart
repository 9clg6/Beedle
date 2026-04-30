import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/tool/store_screenshots/screens/_shared.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// Screen 5 — Editorial home: 1 suggestion du jour + 2-3 à revoir.
class Screen05Home extends StatelessWidget {
  const Screen05Home({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme t = AppTypography.textTheme(
      primary: AppColors.ink,
      secondary: AppColors.neutral6,
    );
    return AuroraCanvas(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CalmSpace.s7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Bonjour, Clement',
                    style: t.displaySmall?.copyWith(fontSize: 30, height: 1.1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Une chose à lire aujourd'hui. Rien de plus.",
                    style: t.bodyLarge?.copyWith(color: AppColors.neutral6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CalmSpace.s7),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: CalmSpace.s7),
              child: _HeroSuggestion(),
            ),
            const SizedBox(height: CalmSpace.s8),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CalmSpace.s7,
                0,
                CalmSpace.s7,
                CalmSpace.s4,
              ),
              child: Text(
                'À REVOIR',
                style: AppTypography.mono(const TextStyle()).copyWith(
                  fontSize: 11,
                  letterSpacing: 1.3,
                  color: AppColors.neutral5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const _RevisitRow(
              title: 'Mieux dormir : la règle des 10-3-2-1',
              meta: '3 min · Santé',
            ),
            const _RevisitRow(
              title: "5 questions à se poser avant d'acheter",
              meta: '4 min · Finance',
            ),
            const _RevisitRow(
              title: 'Écrire un email qui obtient une réponse',
              meta: '5 min · Communication',
            ),
            const SizedBox(height: CalmSpace.s9),
          ],
        ),
      ),
    );
  }
}

class _HeroSuggestion extends StatelessWidget {
  const _HeroSuggestion();

  @override
  Widget build(BuildContext context) {
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: CalmRadius.xl2,
        cornerSmoothing: 0.6,
      ),
    );
    final TextTheme t = AppTypography.textTheme(
      primary: AppColors.ink,
      secondary: AppColors.neutral6,
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        gradient: RadialGradient(
          center: const Alignment(-0.5, -0.6),
          radius: 1.3,
          colors: <Color>[
            AppColors.peach200,
            AppColors.surface,
            AppColors.canvas.withValues(alpha: 0.8),
          ],
          stops: const <double>[0, 0.55, 1],
        ),
        shadows: CalmShadows.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(CalmSpace.s7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const CalmEyebrow('Suggestion du jour'),
            const SizedBox(height: CalmSpace.s6),
            Text(
              'Le prompt qui\nfait gagner\n1h par jour.',
              style: t.displaySmall?.copyWith(fontSize: 32, height: 1.08),
            ),
            const SizedBox(height: CalmSpace.s5),
            Text(
              "Une astuce repérée sur X : demande toujours un plan avant d'agir avec l'IA. 3 règles simples à tester dès ce matin.",
              style: t.bodyMedium?.copyWith(
                fontSize: 14.5,
                height: 1.5,
                color: AppColors.neutral7,
              ),
            ),
            const SizedBox(height: CalmSpace.s6),
            Row(
              children: <Widget>[
                Text(
                  '6 min',
                  style: AppTypography.mono(const TextStyle()).copyWith(
                    fontSize: 12,
                    color: AppColors.neutral6,
                  ),
                ),
                const SizedBox(width: CalmSpace.s3),
                Container(width: 3, height: 3, color: AppColors.neutral5),
                const SizedBox(width: CalmSpace.s3),
                Text(
                  'via X · @sama',
                  style: AppTypography.mono(const TextStyle()).copyWith(
                    fontSize: 12,
                    color: AppColors.neutral6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RevisitRow extends StatelessWidget {
  const _RevisitRow({required this.title, required this.meta});
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s7,
        vertical: CalmSpace.s4,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.glassSoft,
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.bookmark_border,
              size: 18,
              color: AppColors.neutral7,
            ),
          ),
          const SizedBox(width: CalmSpace.s5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTypography.textTheme(
                    primary: AppColors.ink,
                    secondary: AppColors.neutral6,
                  ).titleLarge?.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: AppTypography.mono(const TextStyle()).copyWith(
                    fontSize: 12,
                    color: AppColors.neutral6,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.neutral4,
          ),
        ],
      ),
    );
  }
}
