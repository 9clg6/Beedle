import 'dart:io';
import 'dart:typed_data' show ByteData;
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/enum/card_intent.enum.dart';
import 'package:beedle/features/onboarding/data/onboarding_baked_cards.provider.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_digital_number.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Écran 14 — Viral moment (full-immersion).
///
/// Affiche les 3 fiches déjà persistées en bibliothèque dans une colonne
/// compacte (pas de scroll, les 3 cards se partagent équitablement
/// l'espace vertical disponible). Tap sur une card → ouvre
/// `CardDetailRoute` en push (retour arrière ramène sur l'onboarding).
///
/// Persistence :
/// - Au `initState()` : `persistPreview()` upsert les 3 cards SANS
///   embedding (zéro network) — l'UUID est désormais valide dans
///   ObjectBox donc le tap peut naviguer vers le détail immédiatement.
/// - Au `finishOnboarding()` (ViewModel) : `persistAll()` upsert avec
///   embedding cette fois — idempotent grâce aux UUID v5.
///
/// Le bouton *Partager* capture la colonne via `RepaintBoundary.toImage()`
/// puis lance le native share sheet via `share_plus`.
class OnboardingViralMomentStep extends ConsumerStatefulWidget {
  const OnboardingViralMomentStep({super.key});

  @override
  ConsumerState<OnboardingViralMomentStep> createState() =>
      _OnboardingViralMomentStepState();
}

class _OnboardingViralMomentStepState
    extends ConsumerState<OnboardingViralMomentStep> {
  final GlobalKey _previewKey = GlobalKey();
  late final Future<List<CardEntity>> _cardsFuture = ref
      .read(onboardingBakedCardsRepositoryProvider)
      .persistPreview();
  bool _sharing = false;

  Future<void> _onShare() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      // Wait an extra frame so the RepaintBoundary surely has painted.
      await WidgetsBinding.instance.endOfFrame;

      final RenderRepaintBoundary? boundary =
          _previewKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      final ByteData? bytes = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (bytes == null) return;

      final Directory dir = await getTemporaryDirectory();
      final File file = File('${dir.path}/beedle-onboarding-preview.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());

      // Async gap above (toImage / toByteData / writeAsBytes) — re-check
      // mounted before touching `context` to compute the iPad popover anchor.
      if (!mounted) return;
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        <XFile>[XFile(file.path)],
        text: LocaleKeys.onboarding_ob14_share_text.tr(),
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.onboarding_ob14_share_failed.tr()),
        ),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _onContinue() => ref.read(onboardingViewModelProvider.notifier).next();

  void _onCardTap(CardEntity card) {
    context.router.push(CardDetailRoute(uuid: card.uuid));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s7,
        CalmSpace.s7,
        CalmSpace.s7,
        CalmSpace.s5,
      ),
      child: Column(
        children: <Widget>[
          CalmDigitalNumber(
            value: LocaleKeys.onboarding_ob14_eyebrow.tr(),
            size: 18,
            color: AppColors.ember,
            letterSpacing: 4,
          ),
          const Gap(CalmSpace.s3),
          Text(
            LocaleKeys.onboarding_ob14_title.tr(),
            style: textTheme.titleLarge?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s2),
          Text(
            LocaleKeys.onboarding_ob14_subtitle.tr(),
            style: textTheme.bodySmall?.copyWith(color: AppColors.neutral6),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s4),
          Expanded(
            child: FutureBuilder<List<CardEntity>>(
              future: _cardsFuture,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<CardEntity>> snap,
                  ) {
                    if (!snap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.ink),
                      );
                    }
                    return RepaintBoundary(
                      key: _previewKey,
                      child: _CardColumn(
                        cards: snap.data!,
                        onCardTap: _onCardTap,
                      ),
                    );
                  },
            ),
          ),
          const Gap(CalmSpace.s4),
          SquircleButton(
            label: LocaleKeys.onboarding_ob14_share_cta.tr(),
            icon: Icons.ios_share_rounded,
            expand: true,
            loading: _sharing,
            onPressed: _onShare,
          ),
          const Gap(CalmSpace.s2),
          SquircleButton(
            label: LocaleKeys.onboarding_ob14_finish_cta.tr(),
            variant: SquircleButtonVariant.ghost,
            expand: true,
            onPressed: _onContinue,
          ),
        ],
      ),
    );
  }
}

/// Colonne compacte affichant les N fiches les unes sous les autres.
/// Chaque card prend une part égale de l'espace vertical — calibrée
/// pour que 3 cards tiennent dans la hauteur restante sans scroll.
class _CardColumn extends StatelessWidget {
  const _CardColumn({required this.cards, required this.onCardTap});

  final List<CardEntity> cards;
  final void Function(CardEntity card) onCardTap;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const Center(
        child: Icon(
          Icons.bookmark_outline,
          color: AppColors.neutral3,
          size: 48,
        ),
      );
    }

    return Column(
      children: <Widget>[
        for (int i = 0; i < cards.length; i++) ...<Widget>[
          Expanded(
            child: _OnboardingPreviewCard(
              card: cards[i],
              onTap: () => onCardTap(cards[i]),
            ),
          ),
          if (i < cards.length - 1) const Gap(CalmSpace.s3),
        ],
      ],
    );
  }
}

class _OnboardingPreviewCard extends StatelessWidget {
  const _OnboardingPreviewCard({required this.card, required this.onTap});

  final CardEntity card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(CalmSpace.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _intentLabel(card.intent),
                  style: textTheme.labelSmall?.copyWith(color: AppColors.ember),
                ),
                const Gap(CalmSpace.s1),
                Text(
                  card.title,
                  style: textTheme.titleSmall?.copyWith(color: AppColors.ink),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(CalmSpace.s2),
                Flexible(
                  child: Text(
                    card.summary,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral6,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Gap(CalmSpace.s3),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.neutral3,
            size: 22,
          ),
        ],
      ),
    );
  }

  String _intentLabel(CardIntent intent) {
    return switch (intent) {
      CardIntent.apply => 'À TESTER',
      CardIntent.read => 'À LIRE',
      CardIntent.reference => 'DOC',
    };
  }
}
