import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/engagement_message.entity.dart';
import 'package:beedle/domain/entities/gamification_state.entity.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/enum/card_intent.enum.dart';
import 'package:beedle/features/gamification/presentation/widgets/streak_badge.dart';
import 'package:beedle/features/home/presentation/providers/home_intent_filter.provider.dart';
import 'package:beedle/features/home/presentation/screens/engagement_home.view_model.dart';
import 'package:beedle/features/home/presentation/screens/home.state.dart';
import 'package:beedle/features/home/presentation/screens/home.view_model.dart';
import 'package:beedle/features/home/presentation/widgets/card_glass_tile.dart';
import 'package:beedle/features/home/presentation/widgets/empty_home.dart';
import 'package:beedle/features/home/presentation/widgets/streak_home_card.dart';
import 'package:beedle/features/home/presentation/widgets/upload_progress_card.dart';
import 'package:beedle/features/paywall/presentation/widgets/home_pro_upsell_card.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/blur_surface.dart';
import 'package:beedle/presentation/widgets/calm_digital_number.dart';
import 'package:beedle/presentation/widgets/calm_segmented_control.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:beedle/presentation/widgets/terminal_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Écran d'accueil — CalmSurface Warm.
///
/// Pattern : Aurora Frame en fond, AppBar glass.strong sticky, greeting
/// typographique (display.small ink), StatsStrip minimaliste (no gradients
/// sur les tiles), suggestion hero en GlassCard avec eyebrow Doto optionnel,
/// liste "à revoir" en CardGlassTile, FAB ink flat (zéro glow).
@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(
        ingestionPipelineServiceProvider,
        (_, _) {},
        fireImmediately: true,
      );
      // Feedback visuel "nouvelle fiche" géré désormais par `UploadProgressCard`
      // (état success). On se contente ici d'invalider les view models pour
      // que la Home se rafraîchisse avec la nouvelle card.
      ref.read(ingestionPipelineServiceProvider).cardGeneratedStream.listen((
        CardEntity card,
      ) {
        if (!mounted) return;
        ref
          ..invalidate(homeViewModelProvider)
          ..invalidate(engagementHomeViewModelProvider);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<HomeState> asyncState = ref.watch(homeViewModelProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const _BeedleAppBar(),
      body: GradientBackground(
        child: Stack(
          children: <Widget>[
            asyncState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace st) =>
                  Center(child: Text(LocaleKeys.common_error_generic.tr())),
              data: (HomeState state) {
                if (state.totalCards == 0) {
                  return SafeArea(
                    bottom: false,
                    child: EmptyHome(
                      onImport: () => context.router.push(const ImportRoute()),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.ink,
                  backgroundColor: AppColors.canvas,
                  onRefresh: () =>
                      ref.read(homeViewModelProvider.notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      CalmSpace.s6,
                      140, // AppBar glass sticky + safeArea (notch iPhone). Évite que l'AppBar recouvre la date.
                      CalmSpace.s6,
                      100,
                    ),
                    children: <Widget>[
                      // Voice Terminal (signature CalmSurface).
                      const _TerminalVoice(),
                      const Gap(CalmSpace.s6),
                      _Greeting(totalCards: state.totalCards),
                      const Gap(CalmSpace.s6),
                      // Streak card dédiée.
                      _HomeStreakCard(
                        onTap: () =>
                            context.router.push(const DashboardRoute()),
                      ),
                      const Gap(CalmSpace.s7),
                      if (state.suggestion != null)
                        _SuggestionHero(
                          card: state.suggestion!,
                          onTap: () => _openCard(context, state.suggestion!),
                        ),
                      const Gap(CalmSpace.s7),
                      const _TodayLessonBlock(),
                      // Upsell Pro — visible uniquement pour les users Free.
                      // Self-hide via le provider isPro si l'user est Pro.
                      const Gap(CalmSpace.s7),
                      const HomeProUpsellCard(),
                      const Gap(CalmSpace.s8),
                      if (state.rewatch.isNotEmpty) ...<Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: CalmSpace.s2,
                            bottom: CalmSpace.s4,
                          ),
                          child: Text(
                            LocaleKeys.home_rewatch_title.tr(),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        const _IntentFilter(),
                        const Gap(CalmSpace.s4),
                        if (_filtered(ref, state.rewatch).isEmpty)
                          _FilterEmptyHint(
                            onReset: () => ref
                                .read(homeIntentFilterProvider.notifier)
                                .set(null),
                          )
                        else
                          ..._filtered(ref, state.rewatch).map(
                            (CardEntity c) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: CalmSpace.s4,
                              ),
                              child: CardGlassTile(
                                card: c,
                                onTap: () => _openCard(context, c),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
            // Upload progress card — overlay sticky au-dessus du body,
            // visible quelle que soit la Home (empty state OU data). Self-hide
            // via AnimatedSwitcher quand idle, donc aucun impact visuel hors
            // upload. Placée par-dessus l'AppBar glass (sous le notch safe-area).
            Positioned(
              top: MediaQuery.paddingOf(context).top + 72,
              left: CalmSpace.s6,
              right: CalmSpace.s6,
              child: const UploadProgressCard(),
            ),
          ],
        ),
      ),
      floatingActionButton: asyncState.maybeWhen(
        data: (HomeState state) => state.totalCards > 0
            ? Padding(
                padding: const EdgeInsets.only(bottom: CalmSpace.s3),
                child: _ImportFab(
                  onTap: () => context.router.push(const ImportRoute()),
                ),
              )
            : const SizedBox.shrink(),
        orElse: SizedBox.shrink,
      ),
    );
  }

  Future<void> _openCard(BuildContext context, CardEntity card) async {
    await context.router.push(CardDetailRoute(uuid: card.uuid));
  }

  List<CardEntity> _filtered(WidgetRef ref, List<CardEntity> cards) {
    final CardIntent? filter = ref.watch(homeIntentFilterProvider);
    if (filter == null) return cards;
    return cards.where((CardEntity c) => c.intent == filter).toList();
  }
}

/// Wrapper Consumer qui injecte le GamificationState dans StreakHomeCard.
class _HomeStreakCard extends ConsumerWidget {
  const _HomeStreakCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<GamificationStateEntity> async = ref.watch(
      _gamificationStreamProvider,
    );
    return async.maybeWhen(
      data: (GamificationStateEntity s) =>
          StreakHomeCard(state: s, onTap: onTap),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// Micro empty state — affiché quand le filter exclut toutes les cards.
class _FilterEmptyHint extends StatelessWidget {
  const _FilterEmptyHint({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CalmSpace.s6),
      child: Column(
        children: <Widget>[
          Text(
            LocaleKeys.home_filter_empty.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral6,
            ),
          ),
          const Gap(CalmSpace.s3),
          TextButton(
            onPressed: onReset,
            child: Text(
              LocaleKeys.home_filter_reset.tr(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloc "Leçon du jour" sur la Home — tap → TodayRoute.
class _TodayLessonBlock extends ConsumerWidget {
  const _TodayLessonBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CardEntity?> async = ref.watch(_todayPreviewProvider);
    return async.maybeWhen(
      data: (CardEntity? card) {
        if (card == null) return const SizedBox.shrink();
        return GlassCard(
          onTap: () => context.router.push(const TodayRoute()),
          elevated: false,
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0x0AFF6B2E),
                  borderRadius: BorderRadius.circular(CalmRadius.md),
                  border: Border.all(color: const Color(0x29FF6B2E)),
                ),
                child: const Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppColors.ember,
                  size: 18,
                ),
              ),
              const Gap(CalmSpace.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      LocaleKeys.home_today_lesson_label.tr(),
                      style: AppTypography.digital(
                        const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ember,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),
                    const Gap(CalmSpace.s1),
                    Text(
                      card.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.neutral4,
              ),
            ],
          ),
        );
      },
      orElse: SizedBox.shrink,
    );
  }
}

final FutureProvider<CardEntity?> _todayPreviewProvider =
    FutureProvider<CardEntity?>((Ref ref) async {
      return ref.read(dailyLessonServiceProvider).pickTodayLesson();
    });

/// Segmented "Toutes / À tester / À lire" (Réf exclu par défaut, trop niche).
class _IntentFilter extends ConsumerWidget {
  const _IntentFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CardIntent? selected = ref.watch(homeIntentFilterProvider);
    return Align(
      alignment: Alignment.centerLeft,
      child: CalmSegmentedControl<CardIntent?>(
        values: const <CardIntent?>[null, CardIntent.apply, CardIntent.read],
        labels: <String>[
          LocaleKeys.home_filter_all.tr(),
          LocaleKeys.home_filter_apply.tr(),
          LocaleKeys.home_filter_read.tr(),
        ],
        selected: selected,
        onChanged: (CardIntent? v) =>
            ref.read(homeIntentFilterProvider.notifier).set(v),
      ),
    );
  }
}

/// AppBar glass.strong sticky — Liquid Glass au-dessus de l'Aurora.
class _BeedleAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _BeedleAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<GamificationStateEntity> asyncStreak = ref.watch(
      _gamificationStreamProvider,
    );

    return ClipRect(
      child: BlurSurface(
        tint: AppColors.glassStrong,
        child: SafeArea(
          bottom: false,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.glassBorder),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              CalmSpace.s6,
              CalmSpace.s3,
              CalmSpace.s5,
              CalmSpace.s4,
            ),
            child: Row(
              children: <Widget>[
                const _LogoMark(),
                const Gap(CalmSpace.s4),
                const CalmDigitalNumber(
                  value: 'BEEDLE',
                  size: 20,
                  letterSpacing: 3,
                  color: AppColors.ink,
                ),
                const Spacer(),
                asyncStreak.maybeWhen(
                  data: (GamificationStateEntity s) => s.currentStreak > 0
                      ? Padding(
                          padding: const EdgeInsets.only(right: CalmSpace.s3),
                          child: StreakBadge(
                            streak: s.currentStreak,
                            onTap: () =>
                                context.router.push(const DashboardRoute()),
                          ),
                        )
                      : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),
                _CircleIconButton(
                  icon: Icons.search_rounded,
                  onTap: () => context.router.push(const SearchRoute()),
                ),
                const Gap(CalmSpace.s3),
                _CircleIconButton(
                  icon: Icons.settings_outlined,
                  onTap: () => context.router.push(const SettingsRoute()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Petit carré ember — logo mark discret à côté du wordmark Doto.
class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.ember,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.glassSoft,
          shape: BoxShape.circle,
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.neutral3),
          ),
        ),
        child: Icon(icon, size: 18, color: AppColors.neutral8),
      ),
    );
  }
}

/// Greeting + stats strip.
class _Greeting extends ConsumerWidget {
  const _Greeting({required this.totalCards});

  final int totalCards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateFormat df = DateFormat.MMMMEEEEd(context.locale.languageCode);

    final AsyncValue<GamificationStateEntity> asyncGami = ref.watch(
      _gamificationStreamProvider,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Eyebrow label.sm, uppercase, +3% tracking.
        Text(
          df.format(DateTime.now()).toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.neutral6,
          ),
        ),
        const Gap(CalmSpace.s3),
        // Display.small, ink flat, -1% tracking.
        Text(
          _greetingForNow().tr(),
          style: textTheme.displaySmall?.copyWith(
            color: AppColors.ink,
          ),
        ),
        const Gap(CalmSpace.s6),
        asyncGami.maybeWhen(
          data: (GamificationStateEntity s) => _StatsStrip(
            totalCards: totalCards,
            tested: 0,
            streak: s.currentStreak,
          ),
          orElse: () =>
              _StatsStrip(totalCards: totalCards, tested: 0, streak: 0),
        ),
      ],
    );
  }

  String _greetingForNow() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return LocaleKeys.home_greeting_morning;
    if (hour < 18) return LocaleKeys.home_greeting_afternoon;
    return LocaleKeys.home_greeting_evening;
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({
    required this.totalCards,
    required this.tested,
    required this.streak,
  });

  final int totalCards;
  final int tested;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatTile(
            value: '$totalCards',
            label: LocaleKeys.home_stats_total
                .tr(namedArgs: <String, String>{'count': ''})
                .trim(),
          ),
        ),
        const Gap(CalmSpace.s3),
        Expanded(
          child: _StatTile(
            value: '$tested',
            label: LocaleKeys.home_stats_tested
                .tr(namedArgs: <String, String>{'count': ''})
                .trim(),
          ),
        ),
        const Gap(CalmSpace.s3),
        Expanded(
          child: _StatTile(
            value: '$streak',
            label: LocaleKeys.home_stats_streak
                .tr(namedArgs: <String, String>{'days': ''})
                .trim(),
            digital: true,
          ),
        ),
      ],
    );
  }
}

/// Stat tile minimaliste — valeur en gras Hanken (ou Doto pour streak),
/// label en body.sm neutral.6. Aucun icône, aucun gradient.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    this.digital = false,
  });

  final String value;
  final String label;
  final bool digital;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: CalmRadius.lg,
        cornerSmoothing: 0.5,
      ),
      side: const BorderSide(color: AppColors.neutral3),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s4,
        vertical: CalmSpace.s4,
      ),
      decoration: ShapeDecoration(
        shape: shape,
        color: AppColors.glassSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (digital)
            CalmDigitalNumber(
              value: value,
              size: 28,
              color: AppColors.ink,
              letterSpacing: 1.5,
            )
          else
            Text(
              value,
              style: textTheme.headlineLarge?.copyWith(
                color: AppColors.ink,
                height: 1,
              ),
            ),
          const Gap(CalmSpace.s2),
          Text(
            label.isEmpty ? '—' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.neutral6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Suggestion hero — GlassCard radius 32, eyebrow label.sm ember, titre
/// display.small ink, body bodyMedium, tags en CalmBadge.
class _SuggestionHero extends StatelessWidget {
  const _SuggestionHero({required this.card, required this.onTap});

  final CardEntity card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GlassCard(
      onTap: onTap,
      cornerRadius: 32,
      padding: const EdgeInsets.all(CalmSpace.s7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                LocaleKeys.home_suggestion_label.tr().toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.ember,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (card.isNew) ...<Widget>[
                const Gap(CalmSpace.s3),
                const _HeroNewBadge(),
              ],
            ],
          ),
          const Gap(CalmSpace.s4),
          Text(
            card.title,
            style: textTheme.displaySmall?.copyWith(
              color: AppColors.ink,
            ),
          ),
          const Gap(CalmSpace.s4),
          Text(
            card.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral7,
            ),
          ),
          const Gap(CalmSpace.s5),
          // Tags inline minimaux — pas de pills (trop larges). Juste du texte
          // hashtag, wrap naturel, ember discret.
          Wrap(
            spacing: CalmSpace.s3,
            runSpacing: CalmSpace.s1,
            children: card.tags.take(5).map((String t) {
              return Text(
                '#$t',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.ember,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// FAB ink flat — zéro glow, zéro gradient. Pressure scale 0.98.
/// Badge « NEW » pour la Suggestion Hero — petit pill ember. Variante
/// visible ici (vs le badge de la list row) car le hero a du room.
class _HeroNewBadge extends StatelessWidget {
  const _HeroNewBadge();

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

class _ImportFab extends StatelessWidget {
  const _ImportFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CalmSpace.s6,
            vertical: CalmSpace.s4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.add_rounded,
                color: AppColors.canvas,
                size: 18,
              ),
              const Gap(CalmSpace.s3),
              Text(
                LocaleKeys.capture_import_title.tr(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.canvas,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final StreamProvider<GamificationStateEntity> _gamificationStreamProvider =
    StreamProvider<GamificationStateEntity>((Ref ref) {
      return ref.watch(gamificationRepositoryProvider).watchState();
    });

final FutureProvider<UserPreferencesEntity> _prefsStreamProvider =
    FutureProvider<UserPreferencesEntity>((Ref ref) async {
      return ref.watch(userPreferencesRepositoryProvider).load();
    });

/// Terminal Card — "Beedle's Voice" §2 Signature Pattern.
///
/// Affiche le prochain message engagement long + historique fade. Tap sur le
/// message courant → CardDetailRoute. Tap carte → drawer historique complet.
class _TerminalVoice extends ConsumerWidget {
  const _TerminalVoice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserPreferencesEntity> prefsAsync = ref.watch(
      _prefsStreamProvider,
    );
    final UserPreferencesEntity? prefs = prefsAsync.value;
    // Zen mode / terminal disabled → hide widget entirely.
    if (prefs != null && (prefs.voiceZenMode || !prefs.voiceTerminalEnabled)) {
      return const SizedBox.shrink();
    }

    final AsyncValue<EngagementHomeState> async = ref.watch(
      engagementHomeViewModelProvider,
    );
    final AsyncValue<GamificationStateEntity> streak = ref.watch(
      _gamificationStreamProvider,
    );

    return async.when(
      loading: () => const TerminalCard(
        currentMessage: null,
        history: <String>[],
      ),
      error: (_, _) => const TerminalCard(
        currentMessage: null,
        history: <String>[],
      ),
      data: (EngagementHomeState state) {
        final int? streakDays = streak.maybeWhen(
          data: (GamificationStateEntity s) =>
              s.currentStreak > 0 ? s.currentStreak : null,
          orElse: () => null,
        );
        return TerminalCard(
          currentMessage: state.current?.content,
          history: state.history
              .map((EngagementMessageEntity m) => m.content)
              .toList(growable: false),
          timestamp: DateTime.now(),
          streakDays: streakDays,
          onExpand: () => _openHistorySheet(context, ref, state),
          onExpandMessage: () async {
            final String? cardUuid = state.current?.cardUuid;
            if (cardUuid == null) return;
            await ref
                .read(engagementHomeViewModelProvider.notifier)
                .markCurrentShown();
            if (context.mounted) {
              unawaited(context.router.push(CardDetailRoute(uuid: cardUuid)));
            }
          },
        );
      },
    );
  }

  Future<void> _openHistorySheet(
    BuildContext context,
    WidgetRef ref,
    EngagementHomeState state,
  ) async {
    if (state.history.isEmpty && state.current == null) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) => _VoiceHistorySheet(state: state),
    );
  }
}

class _VoiceHistorySheet extends StatelessWidget {
  const _VoiceHistorySheet({required this.state});
  final EngagementHomeState state;

  @override
  Widget build(BuildContext context) {
    final List<EngagementMessageEntity> messages = <EngagementMessageEntity>[
      if (state.current != null) state.current!,
      ...state.history,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (BuildContext ctx, ScrollController sc) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(CalmRadius.xl3),
          ),
          child: ColoredBox(
            color: AppColors.ink,
            child: ListView.builder(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(
                CalmSpace.s6,
                CalmSpace.s5,
                CalmSpace.s6,
                CalmSpace.s8,
              ),
              itemCount: messages.length + 1,
              itemBuilder: (BuildContext ctx, int i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: CalmSpace.s5),
                    child: Text(
                      LocaleKeys.voice_log_header.tr(),
                      style: AppTypography.mono(
                        const TextStyle(
                          fontSize: 11,
                          color: AppColors.ember,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }
                final EngagementMessageEntity m = messages[i - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: CalmSpace.s4),
                  child: Text(
                    '> ${m.content}',
                    style: AppTypography.mono(
                      const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE8E4DE),
                        height: 1.6,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
