import 'package:auto_route/auto_route.dart';
import 'package:beedle/features/gamification/presentation/screens/dashboard.state.dart';
import 'package:beedle/features/gamification/presentation/screens/dashboard.view_model.dart';
import 'package:beedle/features/gamification/presentation/widgets/activity_graph.dart';
import 'package:beedle/features/gamification/presentation/widgets/badge_gallery.dart';
import 'package:beedle/features/gamification/presentation/widgets/xp_meter.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_back_button.dart';
import 'package:beedle/presentation/widgets/calm_digital_number.dart';
import 'package:beedle/presentation/widgets/calm_segmented_progress.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

@RoutePage()
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardState> asyncState = ref.watch(
      dashboardViewModelProvider,
    );
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leadingWidth: 60,
        leading: const CalmBackButton(),
        title: Text(
          LocaleKeys.gamification_dashboard_title.tr(),
          style: textTheme.titleLarge,
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: asyncState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object e, StackTrace st) =>
                Center(child: Text(LocaleKeys.common_error_generic.tr())),
            data: (DashboardState state) {
              return ListView(
                padding: const EdgeInsets.all(CalmSpace.s6),
                children: <Widget>[
                  XpMeter(state: state.state),
                  const Gap(CalmSpace.s7),
                  _StreakCard(
                    current: state.state.currentStreak,
                    longest: state.state.longestStreak,
                  ),
                  const Gap(CalmSpace.s7),
                  if (state.currentChallenge != null) ...<Widget>[
                    _SectionTitle(
                      label: LocaleKeys.gamification_challenge_title.tr(),
                    ),
                    const Gap(CalmSpace.s4),
                    GlassCard(
                      padding: const EdgeInsets.all(CalmSpace.s5),
                      elevated: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'challenges.${state.currentChallenge!.type.name}'
                                .tr(),
                            style: textTheme.titleMedium,
                          ),
                          const Gap(CalmSpace.s3),
                          CalmSegmentedProgress(
                            currentIndex: state.currentChallenge!.progress - 1,
                            total: state.currentChallenge!.target,
                            segmentHeight: 6,
                          ),
                          const Gap(CalmSpace.s3),
                          Text(
                            '${state.currentChallenge!.progress} / ${state.currentChallenge!.target}',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(CalmSpace.s7),
                  ],
                  _SectionTitle(
                    label: LocaleKeys.gamification_activity_title.tr(),
                  ),
                  const Gap(CalmSpace.s4),
                  GlassCard(
                    padding: const EdgeInsets.all(CalmSpace.s5),
                    elevated: false,
                    child: ActivityGraph(days: state.days),
                  ),
                  const Gap(CalmSpace.s7),
                  _SectionTitle(
                    label: LocaleKeys.gamification_badges_title.tr(),
                  ),
                  const Gap(CalmSpace.s4),
                  BadgeGallery(unlocked: state.state.unlockedBadges),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Streak card — digital Doto pour le chiffre, label.sm pour le best.
class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.current, required this.longest});
  final int current;
  final int longest;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GlassCard(
      child: Row(
        children: <Widget>[
          CalmDigitalNumber(
            value: current.toString().padLeft(2, '0'),
            size: 48,
            color: AppColors.ember,
            letterSpacing: 3,
          ),
          const Gap(CalmSpace.s6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'JOURS CONSÉCUTIFS',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral6,
                  ),
                ),
                const Gap(CalmSpace.s2),
                Text(
                  LocaleKeys.gamification_streak_longest.tr(
                    namedArgs: <String, String>{'days': '$longest'},
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.neutral6,
      ),
    );
  }
}
