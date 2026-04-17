import 'dart:io';
import 'dart:typed_data' show ByteData;
import 'dart:ui' as ui;

import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/enum/card_intent.enum.dart';
import 'package:beedle/features/onboarding/data/onboarding_baked_cards.provider.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
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
/// Affiche les 3 fiches qui seront persistées dans la bibliothèque
/// (chargées via `OnboardingBakedCardsRepository.loadPreview()`,
/// `withEmbedding: false` — l'embedding est calculé seulement à
/// `finishOnboarding()` côté ViewModel). Le bouton *Partager* capture
/// la stack via `RepaintBoundary.toImage()` puis lance le native share
/// sheet via `share_plus`.
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
      .loadPreview();
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CalmDigitalNumber(
            value: LocaleKeys.onboarding_ob14_eyebrow.tr(),
            size: 18,
            color: AppColors.ember,
            letterSpacing: 4,
          ),
          const Gap(CalmSpace.s4),
          Text(
            LocaleKeys.onboarding_ob14_title.tr(),
            style: textTheme.headlineMedium?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s3),
          Text(
            LocaleKeys.onboarding_ob14_subtitle.tr(),
            style: textTheme.bodyMedium?.copyWith(color: AppColors.neutral6),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s5),
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
                      child: _CardStack(cards: snap.data!),
                    );
                  },
            ),
          ),
          const Gap(CalmSpace.s5),
          SquircleButton(
            label: LocaleKeys.onboarding_ob14_share_cta.tr(),
            icon: Icons.ios_share_rounded,
            variant: SquircleButtonVariant.primary,
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

class _CardStack extends StatelessWidget {
  const _CardStack({required this.cards});

  final List<CardEntity> cards;

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

    final List<Widget> stack = <Widget>[];
    for (int i = cards.length - 1; i >= 0; i--) {
      final CardEntity card = cards[i];
      stack.add(
        Positioned.fill(
          top: i * 16.0,
          left: i * 12.0,
          right: i * 12.0,
          child: _OnboardingPreviewCard(card: card),
        ),
      );
    }
    return Stack(children: stack);
  }
}

class _OnboardingPreviewCard extends StatelessWidget {
  const _OnboardingPreviewCard({required this.card});

  final CardEntity card;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return GlassCard(
      padding: const EdgeInsets.all(CalmSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _intentLabel(card.intent),
            style: textTheme.labelSmall?.copyWith(color: AppColors.ember),
          ),
          const Gap(CalmSpace.s2),
          Text(
            card.title,
            style: textTheme.titleMedium?.copyWith(color: AppColors.ink),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(CalmSpace.s3),
          Text(
            card.summary,
            style: textTheme.bodySmall?.copyWith(color: AppColors.neutral6),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          if (card.tags.isNotEmpty)
            Wrap(
              spacing: CalmSpace.s2,
              runSpacing: CalmSpace.s2,
              children: <Widget>[
                for (final String tag in card.tags.take(3))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CalmSpace.s3,
                      vertical: CalmSpace.s1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.glassSoft,
                      borderRadius: BorderRadius.circular(CalmRadius.pill),
                    ),
                    child: Text(
                      '#$tag',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral6,
                      ),
                    ),
                  ),
              ],
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
