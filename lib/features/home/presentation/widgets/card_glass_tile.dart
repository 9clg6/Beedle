import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
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
                Text(
                  card.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
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
