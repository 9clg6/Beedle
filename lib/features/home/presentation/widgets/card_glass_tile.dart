import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/intent_badge.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// CalmSurface list row variante — card tile pour liste "à revoir" sur Home.
class CardGlassTile extends StatelessWidget {
  const CardGlassTile({required this.card, required this.onTap, super.key});
  final CardEntity card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s6,
        vertical: CalmSpace.s5,
      ),
      cornerRadius: CalmRadius.xl,
      child: Row(
        children: <Widget>[
          IntentBadge(intent: card.intent, compact: true),
          const Gap(CalmSpace.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Title row avec badge NEW inline quand la card vient
                // d'être scannée et pas encore ouverte.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        card.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium,
                      ),
                    ),
                    if (card.isNew) ...<Widget>[
                      const Gap(CalmSpace.s3),
                      const _NewBadge(),
                    ],
                  ],
                ),
                const Gap(CalmSpace.s2),
                Text(
                  card.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Gap(CalmSpace.s4),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: isDark ? AppColors.neutral4Dark : AppColors.neutral4,
          ),
        ],
      ),
    );
  }
}

/// Badge « NEW » — affiché sur les cartes fraîchement scannées et
/// pas encore ouvertes (cf. `CardEntity.isNew`).
///
/// Style : fill ember pill, texte canvas mono bold. Taille volontairement
/// petite pour s'insérer à côté du titre sans le pousser. Conforme à
/// §3 Badge (variant `badge.ember` de DESIGN.md).
class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s3,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.ember,
        borderRadius: BorderRadius.circular(CalmRadius.pill),
      ),
      child: Text(
        'NEW',
        style: AppTypography.mono(
          const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.canvas,
            letterSpacing: 0.8,
            height: 1,
          ),
        ),
      ),
    );
  }
}
