import 'package:beedle/domain/enum/badge_type.enum.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BadgeGallery extends StatelessWidget {
  const BadgeGallery({required this.unlocked, super.key});

  final List<BadgeType> unlocked;

  @override
  Widget build(BuildContext context) {
    const all = BadgeType.values;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: all.length,
      itemBuilder: (context, i) {
        final b = all[i];
        final isUnlocked = unlocked.contains(b);
        return _BadgeTile(badge: b, unlocked: isUnlocked);
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.unlocked});

  final BadgeType badge;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(10),
      cornerRadius: 18,
      backgroundColor: unlocked ? null : cs.surfaceContainerLow.withValues(alpha: 0.4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: unlocked ? 1 : 0.25,
            child: Text(badge.icon, style: const TextStyle(fontSize: 28)),
          ),
          const Gap(4),
          Text(
            badge.name,
            style: textTheme.labelSmall?.copyWith(
              color: unlocked ? cs.onSurface : cs.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
