import 'dart:async';

import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Durée de la simulation de digestion (illusion de traitement IA).
const Duration _kDigestDuration = Duration(milliseconds: 1800);

const String _kSourceAsset = 'assets/onboarding/demo-source-linkedin.png';
const String _kResultAsset = 'assets/onboarding/mockup-card-detail.png';

enum _DemoPhase { source, digesting, result }

/// Écran 13 — Demo simulée 1-tap.
///
/// Affiche un faux screenshot LinkedIn (la "source"), un bouton CTA pour
/// déclencher la digestion, puis un mockup iPhone Card Detail (le
/// "résultat"). L'illusion de traitement IA est faite via un cross-fade
/// + un loader sur ~1.8 s.
///
/// Validator : marque `demoCompleted = true` au tap du CTA → débloque
/// *Continuer* dans la NavBar.
class OnboardingDemoStep extends ConsumerStatefulWidget {
  const OnboardingDemoStep({super.key});

  @override
  ConsumerState<OnboardingDemoStep> createState() => _OnboardingDemoStepState();
}

class _OnboardingDemoStepState extends ConsumerState<OnboardingDemoStep> {
  _DemoPhase _phase = _DemoPhase.source;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Si l'utilisateur revient sur l'écran après l'avoir déjà vu,
    // on remontre directement le résultat plutôt que de relancer
    // la simulation depuis zéro.
    final OnboardingState state = ref.read(onboardingViewModelProvider);
    if (state.demoCompleted) _phase = _DemoPhase.result;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onDigest() {
    if (_phase != _DemoPhase.source) return;
    setState(() => _phase = _DemoPhase.digesting);
    _timer = Timer(_kDigestDuration, () {
      if (!mounted) return;
      ref.read(onboardingViewModelProvider.notifier).markDemoCompleted();
      setState(() => _phase = _DemoPhase.result);
    });
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            LocaleKeys.onboarding_ob13_title.tr(),
            style: textTheme.headlineMedium?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s3),
          Text(
            _captionFor(_phase),
            style: textTheme.bodyMedium?.copyWith(color: AppColors.neutral6),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s5),
          Expanded(
            child: _DemoStage(phase: _phase),
          ),
          const Gap(CalmSpace.s5),
          if (_phase == _DemoPhase.source)
            SquircleButton(
              label: LocaleKeys.onboarding_ob13_cta_digest.tr(),
              icon: Icons.auto_awesome_rounded,
              variant: SquircleButtonVariant.primary,
              expand: true,
              onPressed: _onDigest,
            ),
        ],
      ),
    );
  }

  String _captionFor(_DemoPhase phase) {
    return switch (phase) {
      _DemoPhase.source => LocaleKeys.onboarding_ob13_subtitle.tr(),
      _DemoPhase.digesting => LocaleKeys.onboarding_ob13_digesting.tr(),
      _DemoPhase.result => LocaleKeys.onboarding_ob13_result_caption.tr(),
    };
  }
}

class _DemoStage extends StatelessWidget {
  const _DemoStage({required this.phase});

  final _DemoPhase phase;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: CalmDuration.expressive,
      switchInCurve: CalmCurves.emphasized,
      switchOutCurve: CalmCurves.standard,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: switch (phase) {
        _DemoPhase.source => const _StageImage(
          key: ValueKey<String>('source'),
          assetPath: _kSourceAsset,
        ),
        _DemoPhase.digesting => const _DigestingOverlay(
          key: ValueKey<String>('digesting'),
        ),
        _DemoPhase.result => const _StageImage(
          key: ValueKey<String>('result'),
          assetPath: _kResultAsset,
        ),
      },
    );
  }
}

class _StageImage extends StatelessWidget {
  const _StageImage({required this.assetPath, super.key});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const _AssetMissingPlaceholder(),
      ),
    );
  }
}

class _DigestingOverlay extends StatelessWidget {
  const _DigestingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const _PulseGlyph(),
          const Gap(CalmSpace.s5),
          Text(
            LocaleKeys.onboarding_ob13_digesting.tr(),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.ember),
          ),
        ],
      ),
    );
  }
}

class _PulseGlyph extends StatefulWidget {
  const _PulseGlyph();

  @override
  State<_PulseGlyph> createState() => _PulseGlyphState();
}

class _PulseGlyphState extends State<_PulseGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: CalmCurves.soft),
      ),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.ember.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: AppColors.ember,
          size: 40,
        ),
      ),
    );
  }
}

class _AssetMissingPlaceholder extends StatelessWidget {
  const _AssetMissingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSoft,
        borderRadius: BorderRadius.circular(CalmRadius.xl2),
        border: Border.all(color: AppColors.neutral3),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.neutral3,
          size: 48,
        ),
      ),
    );
  }
}
