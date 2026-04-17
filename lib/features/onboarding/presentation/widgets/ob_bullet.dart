import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Ligne de réassurance des écrans onboarding (permissions, paywall…).
///
/// Icône check ember + texte ink. Partagée entre les permission primers
/// (écrans 10/11) pour éviter la duplication signalée par la review.
class ObBullet extends StatelessWidget {
  const ObBullet({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Icon(
          Icons.check_circle_outline,
          color: AppColors.ember,
          size: 18,
        ),
        const Gap(CalmSpace.s3),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}
