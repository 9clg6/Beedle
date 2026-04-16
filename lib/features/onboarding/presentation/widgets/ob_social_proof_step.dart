import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_digital_number.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

const List<({String quoteKey, String authorKey, String personaKey})>
_kTestimonials = <({String quoteKey, String authorKey, String personaKey})>[
  (
    quoteKey: LocaleKeys.onboarding_ob05_testimonials_t0_quote,
    authorKey: LocaleKeys.onboarding_ob05_testimonials_t0_author,
    personaKey: LocaleKeys.onboarding_ob05_testimonials_t0_persona,
  ),
  (
    quoteKey: LocaleKeys.onboarding_ob05_testimonials_t1_quote,
    authorKey: LocaleKeys.onboarding_ob05_testimonials_t1_author,
    personaKey: LocaleKeys.onboarding_ob05_testimonials_t1_persona,
  ),
  (
    quoteKey: LocaleKeys.onboarding_ob05_testimonials_t2_quote,
    authorKey: LocaleKeys.onboarding_ob05_testimonials_t2_author,
    personaKey: LocaleKeys.onboarding_ob05_testimonials_t2_persona,
  ),
];

/// Écran 05 — Social proof (3 testimonials + 1 stat).
class OnboardingSocialProofStep extends StatelessWidget {
  const OnboardingSocialProofStep({super.key});

  @override
  Widget build(BuildContext context) {
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
          CalmDigitalNumber(
            value: LocaleKeys.onboarding_ob05_eyebrow.tr(),
            size: 18,
            color: AppColors.ember,
            letterSpacing: 4,
          ),
          const Gap(CalmSpace.s4),
          Text(
            LocaleKeys.onboarding_ob05_title.tr(),
            style: textTheme.displaySmall?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s7),
          GlassCard(
            elevated: false,
            padding: const EdgeInsets.all(CalmSpace.s6),
            child: Row(
              children: <Widget>[
                CalmDigitalNumber(
                  value: LocaleKeys.onboarding_ob05_stat_value.tr(),
                  size: 36,
                  color: AppColors.ink,
                ),
                const Gap(CalmSpace.s4),
                Expanded(
                  child: Text(
                    LocaleKeys.onboarding_ob05_stat_label.tr(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(CalmSpace.s5),
          for (final ({
                String quoteKey,
                String authorKey,
                String personaKey,
              })
              t
              in _kTestimonials) ...<Widget>[
            _Testimonial(
              quote: t.quoteKey.tr(),
              author: t.authorKey.tr(),
              persona: t.personaKey.tr(),
            ),
            const Gap(CalmSpace.s4),
          ],
        ],
      ),
    );
  }
}

class _Testimonial extends StatelessWidget {
  const _Testimonial({
    required this.quote,
    required this.author,
    required this.persona,
  });

  final String quote;
  final String author;
  final String persona;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return GlassCard(
      elevated: false,
      padding: const EdgeInsets.all(CalmSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '« $quote »',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.ink),
          ),
          const Gap(CalmSpace.s3),
          Text(
            '$author · $persona',
            style: textTheme.labelSmall?.copyWith(color: AppColors.neutral6),
          ),
        ],
      ),
    );
  }
}
