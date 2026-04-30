import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/pro_status.provider.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/features/home/presentation/widgets/card_glass_tile.dart';
import 'package:beedle/features/paywall/presentation/widgets/contextual_paywall_sheet.dart';
import 'package:beedle/features/search/presentation/screens/search.state.dart';
import 'package:beedle/features/search/presentation/screens/search.view_model.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_back_button.dart';
import 'package:beedle/presentation/widgets/calm_empty_state.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SearchState state = ref.watch(searchViewModelProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leadingWidth: 60,
        leading: const CalmBackButton(),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(CalmSpace.s6),
            child: Column(
              children: <Widget>[
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CalmSpace.s5,
                    vertical: CalmSpace.s3,
                  ),
                  cornerRadius: CalmRadius.xl,
                  elevated: false,
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: AppColors.neutral6,
                      ),
                      const Gap(CalmSpace.s4),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          style: Theme.of(context).textTheme.bodyLarge,
                          cursorColor: AppColors.ink,
                          decoration: InputDecoration(
                            hintText: LocaleKeys.search_placeholder.tr(),
                            hintStyle: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.neutral5),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isCollapsed: true,
                          ),
                          onChanged: (String value) => ref
                              .read(searchViewModelProvider.notifier)
                              .updateQuery(value),
                        ),
                      ),
                      if (state.isSearching)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.neutral6,
                          ),
                        ),
                    ],
                  ),
                ),
                const Gap(CalmSpace.s4),
                // Free-only : bannière gating recherche sémantique cross-months.
                // Apparaît seulement si le user a déjà tapé quelque chose.
                if (state.query.isNotEmpty) const _ProSearchBanner(),
                const Gap(CalmSpace.s4),
                Expanded(
                  child: _buildResults(state),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(SearchState state) {
    if (state.query.isEmpty) {
      return CalmEmptyState(
        title: LocaleKeys.search_placeholder.tr(),
        body:
            'Tape un mot-clé, un concept, une techno. '
            'Beedle cherche sémantiquement.',
      );
    }
    if (state.results.isEmpty && !state.isSearching) {
      return CalmEmptyState(
        digitalGlyph: '---',
        title: LocaleKeys.search_empty.tr(),
        body: 'Rien ne matche. Essaie un autre terme.',
      );
    }
    return ListView.separated(
      itemBuilder: (BuildContext context, int i) {
        final CardEntity c = state.results[i];
        return CardGlassTile(
          card: c,
          onTap: () => context.router.push(CardDetailRoute(uuid: c.uuid)),
        );
      },
      separatorBuilder: (_, _) => const Gap(CalmSpace.s3),
      itemCount: state.results.length,
    );
  }
}

/// Bannière affichée aux users Free pour indiquer que leur recherche
/// est limitée au mois courant. Tap → paywall contextuel `semanticSearch`.
///
/// Rendu `glass.soft` pour rester discret — la bannière ne doit pas
/// gêner la lecture des résultats, juste signaler la limite.
class _ProSearchBanner extends ConsumerWidget {
  const _ProSearchBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isPro = ref.watch(proStatusProvider).value ?? false;
    if (isPro) return const SizedBox.shrink();

    final TextTheme textTheme = Theme.of(context).textTheme;
    return GlassCard(
      elevated: false,
      cornerRadius: CalmRadius.lg,
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s5,
        vertical: CalmSpace.s4,
      ),
      onTap: () => showContextualPaywall(
        context,
        reason: ContextualPaywallReason.semanticSearch,
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.travel_explore_rounded,
            size: 18,
            color: AppColors.ember,
          ),
          const Gap(CalmSpace.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Recherche limitée à ce mois-ci',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.neutral8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Passe Pro pour chercher dans toutes tes cartes.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral6,
                  ),
                ),
              ],
            ),
          ),
          const Gap(CalmSpace.s3),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 16,
            color: AppColors.neutral5,
          ),
        ],
      ),
    );
  }
}
