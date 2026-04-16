import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' show ByteData;
import 'dart:ui' as ui;

import 'package:beedle/domain/entities/onboarding_sample_card.entity.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
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
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const String _kCardsJsonAsset = 'assets/onboarding/samples/cards.json';
const int _kPreviewCount = 3;

/// Écran 14 — Viral moment (full-immersion, share PNG export).
///
/// Charge `cards.json`, projette les cards gardées dans le demo step
/// (capped à 3) dans une stack visuelle. Le bouton *Partager* capture
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
  late final Future<List<OnboardingSampleCard>> _cardsFuture =
      _loadSampleCards();
  bool _sharing = false;

  Future<List<OnboardingSampleCard>> _loadSampleCards() async {
    final String raw = await rootBundle.loadString(_kCardsJsonAsset);
    final List<dynamic> entries = json.decode(raw) as List<dynamic>;
    return entries
        .map(
          (dynamic e) =>
              OnboardingSampleCard.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  List<OnboardingSampleCard> _selectKept(
    List<OnboardingSampleCard> all,
    Set<int> keptIndices,
  ) {
    final List<int> ordered = keptIndices.toList()..sort();
    final List<OnboardingSampleCard> picked = <OnboardingSampleCard>[];
    for (final int idx in ordered) {
      if (idx >= 0 && idx < all.length) picked.add(all[idx]);
      if (picked.length == _kPreviewCount) break;
    }
    return picked;
  }

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

      // sharePositionOrigin avoids the iPad crash described in plan R4.
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
    final OnboardingState state = ref.watch(onboardingViewModelProvider);
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
            child: FutureBuilder<List<OnboardingSampleCard>>(
              future: _cardsFuture,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<OnboardingSampleCard>> snap,
                  ) {
                    if (!snap.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.ink),
                      );
                    }
                    final List<OnboardingSampleCard> picks = _selectKept(
                      snap.data!,
                      state.demoSwipedRightIndices,
                    );
                    return RepaintBoundary(
                      key: _previewKey,
                      child: _CardStack(cards: picks),
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

  final List<OnboardingSampleCard> cards;

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
      final OnboardingSampleCard card = cards[i];
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

  final OnboardingSampleCard card;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return GlassCard(
      padding: const EdgeInsets.all(CalmSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            card.intent.toUpperCase(),
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
          Row(
            children: <Widget>[
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.ember,
              ),
              const Gap(CalmSpace.s2),
              Expanded(
                child: Text(
                  card.actionLabel,
                  style: textTheme.labelSmall?.copyWith(color: AppColors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
