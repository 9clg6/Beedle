import 'package:auto_route/auto_route.dart';
import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_badge.dart';
import 'package:beedle/presentation/widgets/calm_digital_number.dart';
import 'package:beedle/presentation/widgets/calm_segmented_progress.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:beedle/presentation/widgets/pill_chip.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

@RoutePage()
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingState state = ref.watch(onboardingViewModelProvider);

    ref.listen(
      onboardingViewModelProvider.select((OnboardingState s) => s.currentIndex),
      (int? prev, int next) {
        if (_controller.hasClients && _controller.page?.round() != next) {
          _controller.animateToPage(
            next,
            duration: CalmDuration.expressive,
            curve: CalmCurves.emphasized,
          );
        }
      },
    );

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _ProgressIndicator(
                currentIndex: state.currentIndex,
                total: 12,
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    const _OBHero(
                      number: '01',
                      titleKey: LocaleKeys.onboarding_step1_title,
                      subtitleKey: LocaleKeys.onboarding_step1_subtitle,
                    ),
                    const _OBHero(
                      number: '02',
                      titleKey: LocaleKeys.onboarding_step2_title,
                      subtitleKey: LocaleKeys.onboarding_step2_subtitle,
                    ),
                    const _OBHero(
                      number: '03',
                      titleKey: LocaleKeys.onboarding_step3_title,
                      subtitleKey: LocaleKeys.onboarding_step3_subtitle,
                    ),
                    const _OBHero(
                      number: '04',
                      titleKey: LocaleKeys.onboarding_step4_title,
                      subtitleKey: LocaleKeys.onboarding_step4_subtitle,
                    ),
                    const _OBHero(
                      number: '05',
                      titleKey: LocaleKeys.onboarding_step5_title,
                      subtitleKey: LocaleKeys.onboarding_step5_subtitle,
                    ),
                    const _OBQuizStep(),
                    _OBPermissionStep(
                      number: '07',
                      titleKey: LocaleKeys.onboarding_step7_title,
                      subtitleKey: LocaleKeys.onboarding_step7_subtitle,
                      ctaKey: LocaleKeys.onboarding_step7_cta,
                      granted: state.notificationsGranted,
                      onRequest: () => ref
                          .read(onboardingViewModelProvider.notifier)
                          .requestNotifications(),
                    ),
                    _OBPermissionStep(
                      number: '08',
                      titleKey: LocaleKeys.onboarding_step8_title,
                      subtitleKey: LocaleKeys.onboarding_step8_subtitle,
                      ctaKey: LocaleKeys.onboarding_step8_cta,
                      granted: state.photosGranted,
                      onRequest: () => ref
                          .read(onboardingViewModelProvider.notifier)
                          .requestPhotos(),
                    ),
                    const _OBHero(
                      number: '09',
                      titleKey: LocaleKeys.onboarding_step9_title,
                      subtitleKey: LocaleKeys.onboarding_step9_subtitle,
                    ),
                    const _OBPaywallStep(),
                    const _OBHero(
                      number: '11',
                      titleKey: LocaleKeys.onboarding_step11_title,
                      subtitleKey: LocaleKeys.onboarding_step11_subtitle,
                    ),
                    _OBAhaStep(
                      onFinish: () async {
                        await ref
                            .read(onboardingViewModelProvider.notifier)
                            .finishOnboarding();
                        if (context.mounted) {
                          await context.router.replace(const HomeRoute());
                        }
                      },
                    ),
                  ],
                ),
              ),
              _NavBar(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.currentIndex, required this.total});
  final int currentIndex;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s6,
        CalmSpace.s5,
        CalmSpace.s6,
        0,
      ),
      child: CalmSegmentedProgress(
        currentIndex: currentIndex,
        total: total,
      ),
    );
  }
}

class _NavBar extends ConsumerWidget {
  const _NavBar({required this.state});
  final OnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int i = state.currentIndex;
    final bool canSkip = i >= 5 && i < 9;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s6,
        CalmSpace.s4,
        CalmSpace.s6,
        CalmSpace.s6,
      ),
      child: Row(
        children: <Widget>[
          if (i > 0)
            SquircleButton(
              label: LocaleKeys.common_action_back.tr(),
              variant: SquircleButtonVariant.ghost,
              onPressed: () =>
                  ref.read(onboardingViewModelProvider.notifier).previous(),
            ),
          const Spacer(),
          if (canSkip)
            SquircleButton(
              label: LocaleKeys.common_action_skip.tr(),
              variant: SquircleButtonVariant.ghost,
              onPressed: () =>
                  ref.read(onboardingViewModelProvider.notifier).goTo(i + 1),
            ),
          if (i < 11)
            SquircleButton(
              label: LocaleKeys.common_action_next.tr(),
              icon: Icons.arrow_forward_rounded,
              onPressed: () =>
                  ref.read(onboardingViewModelProvider.notifier).next(),
            ),
        ],
      ),
    );
  }
}

/// Hero typographique — remplace les cercles gradient + icons.
/// Numéro en Doto (Digital Display §2.4), titre display.sm ink, body.lg.
class _OBHero extends StatelessWidget {
  const _OBHero({
    required this.number,
    required this.titleKey,
    required this.subtitleKey,
  });

  final String number;
  final String titleKey;
  final String subtitleKey;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(CalmSpace.s7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CalmDigitalNumber(
            value: number,
            size: 56,
            color: AppColors.ember,
            letterSpacing: 4,
          ),
          const Gap(CalmSpace.s9),
          Text(
            titleKey.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              subtitleKey.tr(),
              style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _OBQuizStep extends ConsumerWidget {
  const _OBQuizStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingViewModelProvider);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(CalmSpace.s7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Gap(CalmSpace.s5),
          const CalmDigitalNumber(
            value: '06',
            size: 28,
            color: AppColors.ember,
            letterSpacing: 3,
          ),
          const Gap(CalmSpace.s5),
          Text(
            LocaleKeys.onboarding_step6_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s4),
          Text(
            LocaleKeys.onboarding_step6_subtitle.tr(),
            style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
          ),
          const Gap(CalmSpace.s8),
          _QuizLabel(label: LocaleKeys.onboarding_step6_q1_label.tr()),
          const Gap(CalmSpace.s4),
          Wrap(
            spacing: CalmSpace.s3,
            runSpacing: CalmSpace.s3,
            children: <Widget>[
              for (final ContentCategory c in ContentCategory.values)
                PillChip(
                  label: _categoryLabel(c),
                  selected: state.contentCategories.contains(c),
                  onTap: () => ref
                      .read(onboardingViewModelProvider.notifier)
                      .toggleCategory(c),
                ),
            ],
          ),
          const Gap(CalmSpace.s7),
          _QuizLabel(label: LocaleKeys.onboarding_step6_q2_label.tr()),
          const Gap(CalmSpace.s4),
          Wrap(
            spacing: CalmSpace.s3,
            children: <Widget>[
              _CountChip(
                count: 0,
                selected: state.teaserCountPerDay == 0,
                onTap: () => ref
                    .read(onboardingViewModelProvider.notifier)
                    .setTeaserCount(0),
              ),
              _CountChip(
                count: 1,
                selected: state.teaserCountPerDay == 1,
                onTap: () => ref
                    .read(onboardingViewModelProvider.notifier)
                    .setTeaserCount(1),
              ),
              _CountChip(
                count: 2,
                selected: state.teaserCountPerDay == 2,
                onTap: () => ref
                    .read(onboardingViewModelProvider.notifier)
                    .setTeaserCount(2),
              ),
            ],
          ),
          const Gap(CalmSpace.s7),
          _QuizLabel(label: LocaleKeys.onboarding_step6_q3_label.tr()),
          const Gap(CalmSpace.s4),
          Wrap(
            spacing: CalmSpace.s3,
            runSpacing: CalmSpace.s3,
            children: <Widget>[
              for (final int h in <int>[8, 12, 17, 20, 22])
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

  String _categoryLabel(ContentCategory c) {
    return 'onboarding.step6.q1_options.${c.name}'.tr();
  }
}

class _QuizLabel extends StatelessWidget {
  const _QuizLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.neutral6,
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String label = count == 0
        ? 'onboarding.step6.q2_options.none'
        : count == 1
        ? 'onboarding.step6.q2_options.one'
        : 'onboarding.step6.q2_options.two';
    return PillChip(label: label.tr(), selected: selected, onTap: onTap);
  }
}

class _OBPermissionStep extends StatelessWidget {
  const _OBPermissionStep({
    required this.number,
    required this.titleKey,
    required this.subtitleKey,
    required this.ctaKey,
    required this.granted,
    required this.onRequest,
  });

  final String number;
  final String titleKey;
  final String subtitleKey;
  final String ctaKey;
  final bool granted;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(CalmSpace.s7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CalmDigitalNumber(
            value: number,
            size: 56,
            color: AppColors.ember,
            letterSpacing: 4,
          ),
          const Gap(CalmSpace.s9),
          Text(
            titleKey.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              subtitleKey.tr(),
              style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(CalmSpace.s8),
          SquircleButton(
            label: granted ? ctaKey.tr() : ctaKey.tr(),
            icon: granted ? Icons.check_rounded : Icons.arrow_forward_rounded,
            variant: granted
                ? SquircleButtonVariant.secondary
                : SquircleButtonVariant.primary,
            onPressed: granted ? null : onRequest,
          ),
        ],
      ),
    );
  }
}

class _OBPaywallStep extends StatelessWidget {
  const _OBPaywallStep();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(CalmSpace.s7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const CalmBadge(
            label: 'BEEDLE PRO',
            variant: CalmBadgeVariant.mint,
          ),
          const Gap(CalmSpace.s5),
          Text(
            LocaleKeys.onboarding_step10_title.tr(),
            style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s7),
          GlassCard(
            padding: const EdgeInsets.all(CalmSpace.s5),
            elevated: false,
            child: Column(
              children: <Widget>[
                _PlanTile(
                  label: LocaleKeys.onboarding_step10_yearly.tr(),
                  price: '59€',
                  period: '/an',
                  highlighted: true,
                  badge: LocaleKeys.onboarding_step10_yearly_badge.tr(),
                ),
                const SizedBox(height: CalmSpace.s3),
                _PlanTile(
                  label: LocaleKeys.onboarding_step10_monthly.tr(),
                  price: '9€',
                  period: '/mois',
                ),
              ],
            ),
          ),
          const Gap(CalmSpace.s6),
          SquircleButton(
            label: LocaleKeys.onboarding_step9_cta_trial.tr(),
            variant: SquircleButtonVariant.mint,
            expand: true,
            onPressed: () {
              // TODO-USER: SubscriptionRepository.purchase(productId).
            },
          ),
          const Gap(CalmSpace.s2),
          SquircleButton(
            label: LocaleKeys.onboarding_step9_cta_free.tr(),
            variant: SquircleButtonVariant.ghost,
            expand: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.label,
    required this.price,
    required this.period,
    this.highlighted = false,
    this.badge,
  });
  final String label;
  final String price;
  final String period;
  final bool highlighted;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(CalmSpace.s5),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.ink : AppColors.glassSoft,
        borderRadius: BorderRadius.circular(CalmRadius.lg),
        border: highlighted ? null : Border.all(color: AppColors.neutral3),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: textTheme.titleMedium?.copyWith(
                    color: highlighted ? AppColors.canvas : AppColors.neutral8,
                  ),
                ),
                if (badge != null)
                  Padding(
                    padding: const EdgeInsets.only(top: CalmSpace.s1),
                    child: Text(
                      badge!.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: highlighted
                            ? AppColors.mint
                            : AppColors.neutral6,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            price,
            style: textTheme.headlineMedium?.copyWith(
              color: highlighted ? AppColors.canvas : AppColors.ink,
            ),
          ),
          Text(
            period,
            style: textTheme.bodyMedium?.copyWith(
              color: highlighted ? AppColors.mint : AppColors.neutral6,
            ),
          ),
        ],
      ),
    );
  }
}

class _OBAhaStep extends StatelessWidget {
  const _OBAhaStep({required this.onFinish});
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(CalmSpace.s7),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Digital signature plutôt qu'un icône celebration générique.
          const CalmDigitalNumber(
            value: 'GO',
            size: 72,
            color: AppColors.ember,
            letterSpacing: 6,
          ),
          const Gap(CalmSpace.s9),
          Text(
            LocaleKeys.onboarding_step12_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const Gap(CalmSpace.s4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              LocaleKeys.onboarding_step12_subtitle.tr(),
              style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(CalmSpace.s8),
          SquircleButton(
            label: LocaleKeys.onboarding_step12_cta.tr(),
            icon: Icons.arrow_forward_rounded,
            onPressed: onFinish,
          ),
        ],
      ),
    );
  }
}
