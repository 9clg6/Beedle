import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/tool/store_screenshots/screens/_shared.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// Screen 9 — Social proof: rating + a couple of user quotes.
class Screen09Social extends StatelessWidget {
  const Screen09Social({super.key});

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
                padding: const EdgeInsets.fromLTRB(
                  CalmSpace.s7,
                  CalmSpace.s7,
                  CalmSpace.s7,
                  CalmSpace.s7,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const CalmEyebrow('Les utilisateurs'),
                    const SizedBox(height: CalmSpace.s5),
                    Text(
                      'Une veille\nqui se termine.',
                      style: t.displaySmall?.copyWith(fontSize: 32, height: 1.1),
                    ),
                    const SizedBox(height: CalmSpace.s8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '4.8',
                          style: AppTypography.digital(const TextStyle()).copyWith(
                            fontSize: 72,
                            color: AppColors.ember,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: CalmSpace.s4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                children: List<Widget>.generate(
                                  5,
                                  (int i) => const Padding(
                                    padding: EdgeInsets.only(right: 2),
                                    child: Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'sur 312 avis',
                                style: AppTypography.mono(const TextStyle()).copyWith(
                                  fontSize: 12,
                                  color: AppColors.neutral6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: CalmSpace.s8),
                    const _Quote(
                      text: "« J'ai enfin arrêté de capturer dans le vide. »",
                      author: 'Léa · Paris',
                    ),
                    const SizedBox(height: CalmSpace.s5),
                    const _Quote(
                      text: "« La notif du matin m'a fait relire une astuce que j'aurais oubliée. »",
                      author: 'Julien · Lyon',
                    ),
                    const Spacer(),
                    const InkCta(label: 'Commencer · 7 jours gratuits'),
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

class _Quote extends StatelessWidget {
  const _Quote({required this.text, required this.author});
  final String text;
  final String author;

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
        shadows: CalmShadows.md,
      ),
      child: Padding(
        padding: const EdgeInsets.all(CalmSpace.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text,
              style: t.titleLarge?.copyWith(fontSize: 16.5, height: 1.4),
            ),
            const SizedBox(height: CalmSpace.s4),
            Text(
              author,
              style: AppTypography.mono(const TextStyle()).copyWith(
                fontSize: 12,
                color: AppColors.neutral6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
