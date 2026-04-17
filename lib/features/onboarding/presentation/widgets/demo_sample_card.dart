import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Mini-card affichée dans le Demo step (écran 13) — un sample PNG
/// + un titre + un caption "swipe →" / "← swipe pour passer".
class DemoSampleCard extends StatelessWidget {
  const DemoSampleCard({
    required this.assetPath,
    required this.title,
    super.key,
  });

  final String assetPath;
  final String title;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: '$title — swipe à droite pour garder, à gauche pour passer',
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(CalmRadius.xl2),
                ),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.glassSoft,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.neutral3,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(CalmSpace.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                  const Gap(CalmSpace.s3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '← passer',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral6,
                        ),
                      ),
                      Text(
                        'garder →',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.ember,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
