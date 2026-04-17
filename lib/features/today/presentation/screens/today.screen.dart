import 'package:auto_route/auto_route.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/features/today/presentation/screens/today.view_model.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_back_button.dart';
import 'package:beedle/presentation/widgets/calm_empty_state.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Today — écran dédié "Leçon du jour".
///
/// Déclenché depuis :
/// - Le bloc "Aujourd'hui" sur la Home (tap)
/// - Une push notification matinale (deep-link `beedle://lesson`)
@RoutePage()
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CardEntity?> async = ref.watch(todayViewModelProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leadingWidth: 60,
        leading: const CalmCloseButton(),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object e, StackTrace st) => const Center(child: Text('—')),
            data: (CardEntity? card) {
              if (card == null) return const _EmptyToday();
              return _LessonBody(card: card);
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyToday extends StatelessWidget {
  const _EmptyToday();

  @override
  Widget build(BuildContext context) {
    return CalmEmptyState(
      digitalGlyph: '---',
      title: LocaleKeys.today_empty_title.tr(),
      body: LocaleKeys.today_empty_body.tr(),
    );
  }
}

class _LessonBody extends ConsumerWidget {
  const _LessonBody({required this.card});
  final CardEntity card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s7,
        CalmSpace.s5,
        CalmSpace.s7,
        CalmSpace.s9,
      ),
      children: <Widget>[
        // Header eyebrow en Doto orange.
        Text(
          LocaleKeys.today_header.tr(),
          style: AppTypography.digital(
            const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ember,
              letterSpacing: 2.5,
            ),
          ),
        ),
        const Gap(CalmSpace.s7),
        // Titre.
        Text(
          card.title,
          style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
        ),
        const Gap(CalmSpace.s4),
        // Summary.
        Text(
          card.summary,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral7),
        ),
        // Primary action si dispo.
        if (card.primaryAction != null) ...<Widget>[
          const Gap(CalmSpace.s8),
          _ActionBlock(action: card.primaryAction!),
        ],
        const Gap(CalmSpace.s9),
        // CTAs.
        SquircleButton(
          label: LocaleKeys.today_done.tr(),
          icon: Icons.check_rounded,
          expand: true,
          onPressed: () async {
            await ref.read(todayViewModelProvider.notifier).markDone(card.uuid);
          },
        ),
        const Gap(CalmSpace.s3),
        SquircleButton(
          label: LocaleKeys.today_open_card.tr(),
          icon: Icons.arrow_forward_rounded,
          variant: SquircleButtonVariant.secondary,
          expand: true,
          onPressed: () =>
              context.router.push(CardDetailRoute(uuid: card.uuid)),
        ),
        const Gap(CalmSpace.s3),
        SquircleButton(
          label: LocaleKeys.today_remind_later.tr(),
          variant: SquircleButtonVariant.ghost,
          expand: true,
          onPressed: () => context.router.maybePop(),
        ),
      ],
    );
  }
}

class _ActionBlock extends StatelessWidget {
  const _ActionBlock({required this.action});
  final String action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CalmSpace.s6),
      decoration: BoxDecoration(
        color: const Color(0x0AFF6B2E), // ember 4%
        borderRadius: BorderRadius.circular(CalmRadius.xl),
        border: Border.all(color: const Color(0x29FF6B2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            LocaleKeys.today_action_label.tr(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.ember,
              letterSpacing: 1.8,
            ),
          ),
          const Gap(CalmSpace.s3),
          Text(
            action,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.neutral8,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
