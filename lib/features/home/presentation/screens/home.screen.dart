import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/gamification_state.entity.dart';
import 'package:beedle/features/gamification/presentation/widgets/streak_badge.dart';
import 'package:beedle/features/home/presentation/screens/home.state.dart';
import 'package:beedle/features/home/presentation/screens/home.view_model.dart';
import 'package:beedle/features/home/presentation/widgets/card_glass_tile.dart';
import 'package:beedle/features/home/presentation/widgets/empty_home.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/blur_surface.dart';
import 'package:beedle/presentation/widgets/calm_badge.dart';
import 'package:beedle/presentation/widgets/calm_digital_number.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

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
        (_, __) {},
        fireImmediately: true,
      );
      ref.read(ingestionPipelineServiceProvider).cardGeneratedStream.listen((_) {
        if (!mounted) return;
        ref.invalidate(homeViewModelProvider);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(homeViewModelProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const _BeedleAppBar(),
      body: GradientBackground(
        child: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, st) =>
              Center(child: Text(LocaleKeys.common_error_generic.tr())),
          data: (state) {
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
              onRefresh: () => ref.read(homeViewModelProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  CalmSpace.s6,
                  140, // AppBar glass sticky + safeArea (notch iPhone). Évite que l'AppBar recouvre la date.
                  CalmSpace.s6,
                  100,
                ),
                children: <Widget>[
                  _Greeting(totalCards: state.totalCards),
                  const Gap(CalmSpace.s8),
                  if (state.suggestion != null)
                    _SuggestionHero(
                      card: state.suggestion!,
                      onTap: () => _openCard(context, state.suggestion!),
                    ),
                  const Gap(CalmSpace.s9),
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
                    ...state.rewatch.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: CalmSpace.s4),
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
      ),
      floatingActionButton: asyncState.maybeWhen(
        data: (state) => state.totalCards > 0
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

  void _openCard(BuildContext context, CardEntity card) {
    context.router.push(CardDetailRoute(uuid: card.uuid));
  }
}

/// AppBar glass.strong sticky — Liquid Glass au-dessus de l'Aurora.
class _BeedleAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _BeedleAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStreak =
        ref.watch(_gamificationStreamProvider);

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
                // Wordmark en Doto — §2.4 Digital Display.
                const CalmDigitalNumber(
                  value: 'BEEDLE',
                  size: 20,
                  letterSpacing: 3,
                  color: AppColors.ink,
                ),
                const Spacer(),
                asyncStreak.maybeWhen(
                  data: (s) => s.currentStreak > 0
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
    final textTheme = Theme.of(context).textTheme;
    final df = DateFormat.MMMMEEEEd(context.locale.languageCode);

    final asyncGami =
        ref.watch(_gamificationStreamProvider);

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
          data: (s) => _StatsStrip(
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
    final hour = DateTime.now().hour;
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
    final textTheme = Theme.of(context).textTheme;

    final shape = SmoothRectangleBorder(
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
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      onTap: onTap,
      cornerRadius: 32,
      padding: const EdgeInsets.all(CalmSpace.s7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            LocaleKeys.home_suggestion_label.tr().toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.ember,
              fontWeight: FontWeight.w700,
            ),
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
          const Gap(CalmSpace.s6),
          Wrap(
            spacing: CalmSpace.s3,
            runSpacing: CalmSpace.s3,
            children: card.tags.take(3).map((t) {
              return CalmBadge(label: '#$t');
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// FAB ink flat — zéro glow, zéro gradient. Pressure scale 0.98.
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
    StreamProvider<GamificationStateEntity>((ref) {
  return ref.watch(gamificationRepositoryProvider).watchState();
});
