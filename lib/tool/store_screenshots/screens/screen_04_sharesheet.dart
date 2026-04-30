import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// Screen 4 — iOS-style share sheet with Beedle highlighted.
class Screen04ShareSheet extends StatelessWidget {
  const Screen04ShareSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3)),
      child: const Stack(
        children: <Widget>[
          Positioned.fill(child: _TweetBackdrop()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0x55000000)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(top: false, child: _Sheet()),
          ),
        ],
      ),
    );
  }
}

class _TweetBackdrop extends StatelessWidget {
  const _TweetBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.canvas),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CalmSpace.s7),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.arrow_back, color: AppColors.ink),
                  const SizedBox(width: CalmSpace.s5),
                  Text(
                    'Post',
                    style: AppTypography.textTheme(
                      primary: AppColors.ink,
                      secondary: AppColors.neutral6,
                    ).titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: CalmSpace.s7),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: CalmSpace.s7),
              child: _FakeTweet(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FakeTweet extends StatelessWidget {
  const _FakeTweet();

  @override
  Widget build(BuildContext context) {
    final TextTheme t = AppTypography.textTheme(
      primary: AppColors.ink,
      secondary: AppColors.neutral6,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.neutral3,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: CalmSpace.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('Sam Altman', style: t.titleMedium),
                  const SizedBox(width: 4),
                  Text(
                    '@sama · 2h',
                    style: t.bodySmall?.copyWith(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Petite astuce : demande toujours un plan avant d'attaquer quoi que ce soit avec l'IA. 3 règles simples, 1h de gagnée par jour.",
                style: t.bodyLarge?.copyWith(height: 1.45),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet();

  @override
  Widget build(BuildContext context) {
    const SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius.only(
        topLeft: SmoothRadius(cornerRadius: CalmRadius.xl3, cornerSmoothing: 0.7),
        topRight: SmoothRadius(cornerRadius: CalmRadius.xl3, cornerSmoothing: 0.7),
      ),
    );
    return DecoratedBox(
      decoration: const ShapeDecoration(
        shape: shape,
        color: AppColors.canvas,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CalmSpace.s5,
          CalmSpace.s4,
          CalmSpace.s5,
          CalmSpace.s9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: CalmSpace.s6),
            Text(
              'Envoyer vers',
              style: AppTypography.textTheme(
                primary: AppColors.neutral6,
                secondary: AppColors.neutral6,
              ).labelMedium?.copyWith(fontSize: 13, letterSpacing: 1),
            ),
            const SizedBox(height: CalmSpace.s5),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _Target(label: 'Messages', color: AppColors.neutral3),
                _Target(label: 'Mail', color: AppColors.neutral2),
                _Target(label: 'Notes', color: AppColors.neutral3),
                _Target(
                  label: 'Beedle',
                  color: AppColors.ember,
                  featured: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Target extends StatelessWidget {
  const _Target({
    required this.label,
    required this.color,
    this.featured = false,
  });
  final String label;
  final Color color;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final Widget icon = Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: featured
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.ember.withValues(alpha: 0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : const <BoxShadow>[],
      ),
      alignment: Alignment.center,
      child: featured
          ? Text(
              'b',
              style: AppTypography.digital(const TextStyle()).copyWith(
                fontSize: 34,
                color: AppColors.ink,
                height: 1,
              ),
            )
          : null,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        icon,
        const SizedBox(height: CalmSpace.s3),
        SizedBox(
          width: 62,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.textTheme(
              primary: featured ? AppColors.ink : AppColors.neutral7,
              secondary: AppColors.neutral6,
            ).labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: featured ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}
