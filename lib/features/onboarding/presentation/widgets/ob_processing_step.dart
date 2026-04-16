import 'dart:async';

import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

const Duration _kAutoAdvance = Duration(seconds: 2);

const List<String> _kLineKeys = <String>[
  LocaleKeys.onboarding_ob12_lines_l0,
  LocaleKeys.onboarding_ob12_lines_l1,
  LocaleKeys.onboarding_ob12_lines_l2,
];

/// Écran 12 — Processing (full-immersion, auto-advance after 2s).
class OnboardingProcessingStep extends ConsumerStatefulWidget {
  const OnboardingProcessingStep({super.key});

  @override
  ConsumerState<OnboardingProcessingStep> createState() =>
      _OnboardingProcessingStepState();
}

class _OnboardingProcessingStepState
    extends ConsumerState<OnboardingProcessingStep> {
  Timer? _timer;
  int _lineIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (Timer t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _lineIndex = (_lineIndex + 1) % _kLineKeys.length;
      });
    });
    Future<void>.delayed(_kAutoAdvance, () {
      if (!mounted) return;
      ref.read(onboardingViewModelProvider.notifier).next();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(CalmSpace.s7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const _PulseIcon(),
          const Gap(CalmSpace.s7),
          Text(
            LocaleKeys.onboarding_ob12_title.tr(),
            style: textTheme.headlineMedium?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s3),
          Text(
            LocaleKeys.onboarding_ob12_subtitle.tr(),
            style: textTheme.bodyMedium?.copyWith(color: AppColors.neutral6),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s7),
          AnimatedSwitcher(
            duration: CalmDuration.standard,
            child: Text(
              _kLineKeys[_lineIndex].tr(),
              key: ValueKey<int>(_lineIndex),
              style: textTheme.labelMedium?.copyWith(color: AppColors.ember),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseIcon extends StatefulWidget {
  const _PulseIcon();

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(parent: _controller, curve: CalmCurves.soft),
      ),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.ember.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: AppColors.ember,
          size: 36,
        ),
      ),
    );
  }
}
