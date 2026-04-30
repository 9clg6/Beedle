import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/enum/card_intent.enum.dart';
import 'package:beedle/features/card_detail/presentation/screens/card_detail.state.dart';
import 'package:beedle/features/card_detail/presentation/screens/card_detail.view_model.dart';
import 'package:beedle/domain/entities/screenshot.entity.dart';
import 'package:beedle/features/card_detail/presentation/widgets/card_markdown_body.dart';
import 'package:beedle/features/card_detail/presentation/widgets/screenshot_thumbnail_strip.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_back_button.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:beedle/presentation/widgets/intent_badge.dart';
import 'package:beedle/presentation/widgets/pill_chip.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class CardDetailScreen extends ConsumerStatefulWidget {
  const CardDetailScreen({required this.uuid, super.key});

  @PathParam('uuid')
  final String uuid;

  @override
  ConsumerState<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends ConsumerState<CardDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final AsyncValue<CardDetailState> asyncState = ref.watch(
      cardDetailViewModelProvider(widget.uuid),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leadingWidth: 60,
        leading: const CalmBackButton(),
      ),
      body: GradientBackground(
        child: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, StackTrace st) =>
              Center(child: Text(LocaleKeys.common_error_generic.tr())),
          data: (CardDetailState state) {
            final CardEntity? card = state.card;
            if (card == null) {
              return Center(child: Text(LocaleKeys.common_empty.tr()));
            }
            return _Body(
              card: card,
              screenshots: state.screenshots,
              uuid: widget.uuid,
            );
          },
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.card,
    required this.screenshots,
    required this.uuid,
  });
  final CardEntity card;
  final List<ScreenshotEntity> screenshots;
  final String uuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          CalmSpace.s6,
          CalmSpace.s10,
          CalmSpace.s6,
          CalmSpace.s9,
        ),
        children: <Widget>[
          // Intent badge tappable — override sheet au tap.
          Row(
            children: <Widget>[
              IntentBadge(
                intent: card.intent,
                onTap: () async {
                  final CardIntent? next = await showIntentOverrideSheet(
                    context,
                    current: card.intent,
                  );
                  if (next == null || next == card.intent) return;
                  await ref
                      .read(cardRepositoryProvider)
                      .setIntent(card.uuid, next);
                  ref.invalidate(cardDetailViewModelProvider(uuid));
                },
              ),
            ],
          ),
          const Gap(CalmSpace.s4),
          // Eyebrow métadata — texte inline séparé par ·
          // (pas de pills fullWidth)
          _MetaRow(
            level: _levelLabel(card),
            minutes: card.estimatedMinutes,
            language: card.language,
          ),
          const Gap(CalmSpace.s6),
          // Title — display.sm, ink flat.
          Text(
            card.title,
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s5),
          // Résumé en GlassCard soft — sans italique, sans icône orange.
          if (card.summary.isNotEmpty)
            GlassCard(
              padding: const EdgeInsets.all(CalmSpace.s5),
              cornerRadius: CalmRadius.xl,
              elevated: false,
              child: Text(
                card.summary,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.neutral7,
                  height: 1.55,
                ),
              ),
            ),
          const Gap(CalmSpace.s7),
          if (screenshots.isNotEmpty) ...<Widget>[
            ScreenshotThumbnailStrip(screenshots: screenshots),
            const Gap(CalmSpace.s7),
          ],
          if (card.tags.isNotEmpty) ...<Widget>[
            Wrap(
              spacing: CalmSpace.s3,
              runSpacing: CalmSpace.s3,
              children: card.tags
                  .map((String t) => PillChip(label: '#$t'))
                  .toList(),
            ),
            const Gap(CalmSpace.s7),
          ],
          // Cœur : markdown rendu.
          CardMarkdownBody(markdown: card.fullContent),
          const Gap(CalmSpace.s8),
          _ActionsBar(card: card, uuid: uuid),
        ],
      ),
    );
  }

  String _levelLabel(CardEntity card) {
    return 'card.level.${card.level.name}'.tr();
  }
}

/// Métadata inline — "Intermédiaire · 10 min · FR" en label.sm neutral.6.
/// Plus discret qu'une rangée de pills.
class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.level,
    required this.language,
    this.minutes,
  });

  final String level;
  final String language;
  final int? minutes;

  @override
  Widget build(BuildContext context) {
    final List<String> parts = <String>[
      level,
      if (minutes != null)
        LocaleKeys.card_estimated_time.tr(
          namedArgs: <String, String>{'minutes': '$minutes'},
        ),
      language.toUpperCase(),
    ];
    return Text(
      parts.join(' · '),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.neutral6,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _ActionsBar extends ConsumerWidget {
  const _ActionsBar({required this.card, required this.uuid});
  final CardEntity card;
  final String uuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Action primaire — ink flat, full width.
        SquircleButton(
          label: LocaleKeys.card_actions_open_with_ai.tr(),
          icon: Icons.auto_awesome_rounded,
          expand: true,
          onPressed: () => _openWithAI(card),
        ),
        const Gap(CalmSpace.s3),
        if (card.sourceUrl != null)
          SquircleButton(
            label: LocaleKeys.card_actions_open_source.tr(),
            icon: Icons.open_in_new_rounded,
            variant: SquircleButtonVariant.secondary,
            expand: true,
            onPressed: () async {
              final Uri url = Uri.parse(card.sourceUrl!);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
        const Gap(CalmSpace.s3),
        SquircleButton(
          label: card.testedAt != null
              ? LocaleKeys.card_actions_tested.tr()
              : LocaleKeys.card_actions_mark_tested.tr(),
          icon: card.testedAt != null
              ? Icons.check_circle_rounded
              : Icons.bookmark_border_rounded,
          variant: SquircleButtonVariant.ghost,
          expand: true,
          onPressed: card.testedAt != null
              ? null
              : () => ref
                    .read(cardDetailViewModelProvider(uuid).notifier)
                    .markTested(),
        ),
      ],
    );
  }

  Future<void> _openWithAI(CardEntity card) async {
    final String prompt = '${card.title}\n\n${card.fullContent}';
    final Uri webFallback = Uri.parse(
      'https://claude.ai/new?q=${Uri.encodeComponent(prompt)}',
    );
    if (await canLaunchUrl(webFallback)) {
      await launchUrl(webFallback, mode: LaunchMode.externalApplication);
    }
  }
}
