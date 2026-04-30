import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/tool/store_screenshots/screens/_shared.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// Screen 6 — Semantic search with a fuzzy query.
class Screen06Search extends StatelessWidget {
  const Screen06Search({super.key});

  @override
  Widget build(BuildContext context) {
    return AuroraCanvas(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: CalmSpace.s7),
              child: _SearchField(),
            ),
            const SizedBox(height: CalmSpace.s4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CalmSpace.s7),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '3 résultats  ·  recherche sémantique',
                  style: AppTypography.mono(const TextStyle()).copyWith(
                    fontSize: 12,
                    color: AppColors.neutral6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: CalmSpace.s5),
            const _Result(
              title: 'La règle des 10-3-2-1 pour mieux dormir',
              snippet: '10h sans café, 3h sans manger, 2h sans travail, 1h sans écran…',
              meta: 'il y a 3 sem  ·  match 0.94',
            ),
            const _Result(
              title: "Respiration 4-7-8 : l'endormissement en 2 min",
              snippet: 'Inspire 4s, retiens 7s, expire 8s — utilisé par les Navy SEALs…',
              meta: 'il y a 1 mois  ·  match 0.82',
            ),
            const _Result(
              title: 'Pourquoi tu te réveilles à 3h du matin',
              snippet: "Le cortisol, la glycémie et l'alcool du soir : 3 causes courantes…",
              meta: 'il y a 2 mois  ·  match 0.78',
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: CalmRadius.xl,
        cornerSmoothing: 0.55,
      ),
      side: const BorderSide(color: AppColors.neutral3),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(shape: shape, color: AppColors.glassSoft),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CalmSpace.s5,
          vertical: 12,
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.search, size: 20, color: AppColors.neutral5),
            const SizedBox(width: CalmSpace.s4),
            Expanded(
              child: Text(
                'ce truc pour mieux dormir…',
                style: AppTypography.textTheme(
                  primary: AppColors.ink,
                  secondary: AppColors.neutral6,
                ).bodyLarge?.copyWith(
                  color: AppColors.ink,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Container(
              width: 2,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.ember,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.title,
    required this.snippet,
    required this.meta,
  });
  final String title;
  final String snippet;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = AppTypography.textTheme(
      primary: AppColors.ink,
      secondary: AppColors.neutral6,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s7,
        vertical: CalmSpace.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: t.titleLarge?.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            snippet,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.bodyMedium?.copyWith(color: AppColors.neutral7),
          ),
          const SizedBox(height: 6),
          Text(
            meta,
            style: AppTypography.mono(const TextStyle()).copyWith(
              fontSize: 11.5,
              color: AppColors.ember,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
