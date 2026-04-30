import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/tool/store_screenshots/screens/_shared.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// Screen 8 — Multi-screen fusion: 3 captures → 1 coherent fiche.
class Screen08Fusion extends StatelessWidget {
  const Screen08Fusion({super.key});

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CalmSpace.s7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const CalmEyebrow('Fusion intelligente'),
                  const SizedBox(height: CalmSpace.s4),
                  Text(
                    '3 screenshots.\n1 fiche cohérente.',
                    style: t.displaySmall?.copyWith(fontSize: 28, height: 1.1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CalmSpace.s7),
            const _FanStack(),
            const SizedBox(height: CalmSpace.s6),
            const _DownArrow(),
            const SizedBox(height: CalmSpace.s6),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: CalmSpace.s7),
              child: _FusedCard(),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _FanStack extends StatelessWidget {
  const _FanStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Transform.translate(
            offset: const Offset(-80, 10),
            child: Transform.rotate(
              angle: -0.18,
              child: const _MiniCapture(lines: 4),
            ),
          ),
          Transform.translate(
            offset: const Offset(80, 10),
            child: Transform.rotate(
              angle: 0.18,
              child: const _MiniCapture(lines: 3),
            ),
          ),
          const _MiniCapture(lines: 5, emphasized: true),
        ],
      ),
    );
  }
}

class _MiniCapture extends StatelessWidget {
  const _MiniCapture({required this.lines, this.emphasized = false});
  final int lines;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.glassStrong,
        border: Border.all(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(12),
        boxShadow: emphasized ? CalmShadows.lg : CalmShadows.sm,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(height: 4, width: 28, color: AppColors.neutral4),
          const SizedBox(height: 10),
          for (int i = 0; i < lines; i++) ...<Widget>[
            Container(
              height: 4,
              width: (i.isEven ? 80 : 64).toDouble(),
              color: AppColors.neutral3,
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _DownArrow extends StatelessWidget {
  const _DownArrow();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.ember.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_downward,
          size: 16,
          color: AppColors.ember,
        ),
      ),
    );
  }
}

class _FusedCard extends StatelessWidget {
  const _FusedCard();

  @override
  Widget build(BuildContext context) {
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: CalmRadius.xl2,
        cornerSmoothing: 0.6,
      ),
      side: const BorderSide(color: AppColors.glassBorderWarm),
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
        padding: const EdgeInsets.all(CalmSpace.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.ember,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Thread unifié',
                  style: AppTypography.mono(const TextStyle()).copyWith(
                    fontSize: 12,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral7,
                  ),
                ),
              ],
            ),
            const SizedBox(height: CalmSpace.s4),
            Text(
              '5 règles pour mieux dormir ce soir',
              style: t.titleLarge?.copyWith(fontSize: 18, height: 1.25),
            ),
            const SizedBox(height: CalmSpace.s3),
            Text(
              '3 posts fusionnés automatiquement en une seule fiche claire.',
              style: t.bodySmall?.copyWith(
                fontSize: 13,
                height: 1.45,
                color: AppColors.neutral6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
