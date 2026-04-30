import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/tool/store_screenshots/screens/_shared.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// Screen 2 — Fiche IA detail. Shows what AI digestion produces.
class Screen02Fiche extends StatelessWidget {
  const Screen02Fiche({super.key});

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
            _TopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  CalmSpace.s7,
                  CalmSpace.s6,
                  CalmSpace.s7,
                  CalmSpace.s5,
                ),
                children: <Widget>[
                  const CalmEyebrow('Fiche · Astuce'),
                  const SizedBox(height: CalmSpace.s5),
                  Text(
                    'Le prompt qui fait gagner 1h par jour',
                    style: t.displaySmall?.copyWith(fontSize: 30, height: 1.1),
                  ),
                  const SizedBox(height: CalmSpace.s5),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.neutral3,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: CalmSpace.s3),
                      Text(
                        '@sama sur X  ·  28 mars',
                        style: AppTypography.mono(const TextStyle()).copyWith(
                          fontSize: 12.5,
                          color: AppColors.neutral6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: CalmSpace.s7),
                  Text(
                    'TL;DR',
                    style: AppTypography.mono(const TextStyle()).copyWith(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: AppColors.neutral5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: CalmSpace.s3),
                  Text(
                    "Demande un plan avant de coder. Trois règles simples pour arrêter les allers-retours inutiles avec l'IA et retrouver du temps.",
                    style: t.bodyLarge?.copyWith(height: 1.55),
                  ),
                  const SizedBox(height: CalmSpace.s7),
                  const _StepsCard(),
                  const SizedBox(height: CalmSpace.s6),
                  const Wrap(
                    spacing: CalmSpace.s3,
                    runSpacing: CalmSpace.s3,
                    children: <Widget>[
                      GlassPill('2 min', icon: Icons.schedule),
                      GlassPill('Productivité'),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                CalmSpace.s7,
                0,
                CalmSpace.s7,
                CalmSpace.s7,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(child: InkCta(label: 'Ouvrir la source')),
                  SizedBox(width: CalmSpace.s4),
                  Expanded(child: OutlineCta(label: 'Avec Claude')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s5,
        CalmSpace.s3,
        CalmSpace.s5,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.ink),
          Text(
            'il y a 2h',
            style: AppTypography.mono(const TextStyle()).copyWith(
              fontSize: 12.5,
              color: AppColors.neutral6,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  const _StepsCard();

  @override
  Widget build(BuildContext context) {
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: CalmRadius.xl2,
        cornerSmoothing: 0.6,
      ),
      side: const BorderSide(color: AppColors.glassBorder),
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        color: AppColors.glassMedium,
        shadows: CalmShadows.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(CalmSpace.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'ÉTAPES',
              style: AppTypography.mono(const TextStyle()).copyWith(
                fontSize: 11,
                letterSpacing: 1.3,
                color: AppColors.neutral5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: CalmSpace.s5),
            const _Step(
              n: '1',
              title: 'Explique ton objectif',
              code: '« Voici ce que je veux… »',
            ),
            const SizedBox(height: CalmSpace.s5),
            const _Step(
              n: '2',
              title: 'Demande un plan écrit',
              code: '« Fais-moi le plan avant de coder »',
            ),
            const SizedBox(height: CalmSpace.s5),
            const _Step(
              n: '3',
              title: 'Valide, puis laisse coder',
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.n, required this.title, this.code});
  final String n;
  final String title;
  final String? code;

  @override
  Widget build(BuildContext context) {
    final TextTheme t = AppTypography.textTheme(
      primary: AppColors.ink,
      secondary: AppColors.neutral6,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 22,
          child: Text(
            n,
            style: AppTypography.mono(const TextStyle()).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ember,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: t.titleMedium?.copyWith(fontSize: 15)),
              if (code != null) ...<Widget>[
                const SizedBox(height: 6),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.neutral8.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: Text(
                      code!,
                      style: AppTypography.mono(const TextStyle()).copyWith(
                        fontSize: 12.5,
                        color: AppColors.neutral8,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
