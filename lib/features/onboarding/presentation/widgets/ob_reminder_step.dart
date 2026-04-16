import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/pill_chip.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

const List<int> _kHourChoices = <int>[8, 12, 17, 20, 22];

/// Écran 09 — Reminder (frequency + hour preference).
///
/// Reuse Pill chips for both. Pas de validator (les defaults sont valides).
class OnboardingReminderStep extends ConsumerWidget {
  const OnboardingReminderStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingViewModelProvider);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s7,
        CalmSpace.s7,
        CalmSpace.s7,
        CalmSpace.s5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            LocaleKeys.onboarding_ob09_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s4),
          Text(
            LocaleKeys.onboarding_ob09_subtitle.tr(),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
          ),
          const Gap(CalmSpace.s7),
          _Label(LocaleKeys.onboarding_ob09_count_label.tr()),
          const Gap(CalmSpace.s4),
          Wrap(
            spacing: CalmSpace.s3,
            children: <Widget>[
              _CountChip(
                label: LocaleKeys.onboarding_ob09_count_options_none.tr(),
                selected: state.teaserCountPerDay == 0,
                onTap: () => ref
                    .read(onboardingViewModelProvider.notifier)
                    .setTeaserCount(0),
              ),
              _CountChip(
                label: 'onboarding.ob09.count_options.one'.tr(),
                selected: state.teaserCountPerDay == 1,
                onTap: () => ref
                    .read(onboardingViewModelProvider.notifier)
                    .setTeaserCount(1),
              ),
              _CountChip(
                label: 'onboarding.ob09.count_options.two'.tr(),
                selected: state.teaserCountPerDay == 2,
                onTap: () => ref
                    .read(onboardingViewModelProvider.notifier)
                    .setTeaserCount(2),
              ),
            ],
          ),
          const Gap(CalmSpace.s7),
          _Label(LocaleKeys.onboarding_ob09_hour_label.tr()),
          const Gap(CalmSpace.s4),
          Wrap(
            spacing: CalmSpace.s3,
            runSpacing: CalmSpace.s3,
            children: <Widget>[
              for (final int h in _kHourChoices)
                PillChip(
                  label: '${h}h',
                  selected: state.captureReminderHour == h,
                  onTap: () => ref
                      .read(onboardingViewModelProvider.notifier)
                      .setReminderHour(h),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: AppColors.neutral6),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PillChip(label: label, selected: selected, onTap: onTap);
  }
}
