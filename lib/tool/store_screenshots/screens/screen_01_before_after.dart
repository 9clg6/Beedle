import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/tool/store_screenshots/screens/_shared.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// Screen 1 — Hero "Before / After" (vertical split).
///
/// Top ~40%: chaotic Photos grid (the "before"), visually muted.
/// Middle: thin transition divider with a small label.
/// Bottom ~60%: one clean Beedle fiche card, full width, well lit.
class Screen01BeforeAfter extends StatelessWidget {
  const Screen01BeforeAfter({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuroraCanvas(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            // Top chaos
            Expanded(
              flex: 40,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  CalmSpace.s7,
                  CalmSpace.s5,
                  CalmSpace.s7,
                  CalmSpace.s4,
                ),
                child: _MessyGrid(),
              ),
            ),
            // Transition divider
            _Divider(),
            // Bottom clean fiche
            Expanded(
              flex: 60,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  CalmSpace.s7,
                  CalmSpace.s6,
                  CalmSpace.s7,
                  CalmSpace.s9,
                ),
                child: _CleanFiche(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s7,
        vertical: CalmSpace.s3,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.neutral3.withValues(alpha: 0.6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CalmSpace.s4),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.ember.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_downward,
                size: 14,
                color: AppColors.ember,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.neutral3.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessyGrid extends StatelessWidget {
  const _MessyGrid();

  @override
  Widget build(BuildContext context) {
    const List<Color> tones = <Color>[
      AppColors.neutral3,
      AppColors.neutral4,
      AppColors.peach100,
      AppColors.peach200,
      AppColors.surface,
      AppColors.neutral2,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'PHOTOS',
          style: AppTypography.mono(const TextStyle()).copyWith(
            fontSize: 11,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral5,
          ),
        ),
        const SizedBox(height: CalmSpace.s4),
        Expanded(
          child: Opacity(
            opacity: 0.78,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 0.78,
              ),
              itemCount: 12,
              itemBuilder: (BuildContext context, int i) {
                final Color bg = tones[i % tones.length];
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          height: 3,
                          width: 20,
                          color: AppColors.neutral6.withValues(alpha: 0.25),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 3,
                              width: 34,
                              color: AppColors.neutral7.withValues(alpha: 0.25),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              height: 3,
                              width: 26,
                              color: AppColors.neutral7.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              height: 3,
                              width: 22,
                              color: AppColors.neutral7.withValues(alpha: 0.18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _CleanFiche extends StatelessWidget {
  const _CleanFiche();

  @override
  Widget build(BuildContext context) {
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: CalmRadius.xl2,
        cornerSmoothing: 0.6,
      ),
      side: const BorderSide(color: AppColors.glassBorder),
    );
    final TextTheme t = AppTypography.textTheme(
      primary: AppColors.ink,
      secondary: AppColors.neutral6,
    );
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        color: AppColors.glassStrong,
        shadows: CalmShadows.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(CalmSpace.s7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CalmEyebrow('Beedle'),
                const SizedBox(height: CalmSpace.s5),
                Text(
                  'La veille\nqui se rappelle\nà toi.',
                  style: t.displaySmall?.copyWith(
                    fontSize: 34,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: CalmSpace.s5),
                Text(
                  "Tes screenshots deviennent des fiches claires. L'app te relance au bon moment pour que tu les lises vraiment.",
                  style: t.bodyLarge?.copyWith(
                    height: 1.5,
                    color: AppColors.neutral7,
                  ),
                ),
              ],
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: CalmSpace.s3,
                  runSpacing: CalmSpace.s3,
                  children: <Widget>[
                    GlassPill('Capture'),
                    GlassPill('Digestion IA'),
                    GlassPill('Rappel'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
