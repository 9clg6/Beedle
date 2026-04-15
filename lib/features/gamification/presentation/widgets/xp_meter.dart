import 'package:beedle/domain/entities/gamification_state.entity.dart';
import 'package:beedle/domain/enum/beedle_level.enum.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class XpMeter extends StatelessWidget {
  const XpMeter({required this.state, super.key});

  final GamificationStateEntity state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final level = state.level;
    final next = level.next;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      cornerRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(level.title, style: textTheme.titleLarge),
                    if (next != null)
                      Text(
                        '${state.totalXp} / ${next.thresholdXp} XP → ${next.title}',
                        style: textTheme.labelSmall,
                      )
                    else
                      Text('${state.totalXp} XP — niveau max atteint 👑', style: textTheme.labelSmall),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.progressToNextLevel,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange500),
            ),
          ),
        ],
      ),
    );
  }
}
