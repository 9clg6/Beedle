import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/auth.provider.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/features/paywall/presentation/widgets/testimonial_carousel.dart';
import 'package:beedle/presentation/widgets/calm_back_button.dart';
import 'package:beedle/presentation/widgets/calm_digital_number.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Paywall Beedle Pro — CalmSurface compliant.
///
/// Signature patterns utilisés :
///   • §2.1 Aurora Frame (auroraWarm) via [GradientBackground]
///   • §2.3 Ember Accent (1× / screen) sur le hero
///   • §2.4 Digital Display (Doto) pour le lockup « BEEDLE · PRO »
///   • §3 Liquid Glass Cards pour bénéfices et pricing
///   • §3 Button primary (ink flat) pour le CTA
///
/// Anti-slop : pas de checkmarks emoji, pas de dégradé violet/bleu,
/// pas de neon glow, pas de "trusted by", Doto une seule fois.
@RoutePage()
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  _Plan _selected = _Plan.yearly;

  @override
  void initState() {
    super.initState();
    // Impression event — source='standalone' pour distinguer le paywall
    // route du paywall onboarding step (déjà loggé dans ob_paywall_step).
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .track(
            AnalyticsEvent.paywallShown,
            properties: <String, Object>{'source': 'standalone'},
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 60,
        leading: const CalmCloseButton(),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await ref
                  .read(analyticsServiceProvider)
                  .track(
                    AnalyticsEvent.subscriptionRestored,
                    properties: const <String, Object>{
                      'source': 'paywall_button',
                    },
                  );
              await ref.read(subscriptionRepositoryProvider).restore();
            },
            child: Text(
              'Restaurer',
              style: textTheme.labelLarge?.copyWith(color: AppColors.neutral6),
            ),
          ),
          const Gap(CalmSpace.s4),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: <Widget>[
              // ───── Scrollable content ─────
              // Le padding bottom réserve la place du sticky + safe-area,
              // sinon le dernier item est masqué sous le glass panel.
              ListView(
                padding: EdgeInsets.fromLTRB(
                  0,
                  CalmSpace.s3,
                  0,
                  _kStickyHeight + MediaQuery.paddingOf(context).bottom,
                ),
                children: <Widget>[
                  // Hero : Ember accent + Doto lockup
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CalmSpace.s7,
                    ),
                    child: const _EmberHeroLockup(),
                  ),
                  const Gap(CalmSpace.s8),

                  // Titre + subhead
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CalmSpace.s7,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Que toutes tes cartes\nchantent à nouveau',
                          style: textTheme.headlineLarge?.copyWith(
                            color: AppColors.neutral8,
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
                        ),
                        const Gap(CalmSpace.s4),
                        Text(
                          'Scan IA sur 100 % de tes trouvailles, et des '
                          'rappels qui les ramènent aux bonnes heures.',
                          style: textTheme.bodyLarge
                              ?.copyWith(color: AppColors.neutral6),
                        ),
                      ],
                    ),
                  ),
                  const Gap(CalmSpace.s7),

                  // ───── Testimonials — carrousel horizontal mis en avant ─────
                  _TestimonialsSection(),
                  const Gap(CalmSpace.s8),

                  // Bénéfices
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CalmSpace.s7,
                    ),
                    child: const GlassCard(
                      elevated: false,
                      child: Column(
                        children: <Widget>[
                          _Benefit(
                            icon: Icons.all_inclusive_rounded,
                            title: 'Scans illimités',
                            body: 'Chaque carte devient recherchable.',
                          ),
                          _BenefitDivider(),
                          _Benefit(
                            icon: Icons.search_rounded,
                            title: 'Recherche par le sens',
                            body:
                                'Retrouve une carte par son idée, pas ses mots.',
                          ),
                          _BenefitDivider(),
                          _Benefit(
                            icon: Icons.notifications_active_rounded,
                            title: 'Rappels adaptatifs',
                            body: 'Au bon moment, groupés par thème.',
                          ),
                          _BenefitDivider(),
                          _Benefit(
                            icon: Icons.ios_share_rounded,
                            title: 'Export Notion · Obsidian',
                            body: 'Ta veille, portable.',
                          ),
                          _BenefitDivider(),
                          _Benefit(
                            icon: Icons.devices_rounded,
                            title: 'Sync multi-device',
                            body: 'iPhone · iPad · Android.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(CalmSpace.s7),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: CalmSpace.s7),
                    child: _LegalLinks(),
                  ),
                ],
              ),

              // ───── Sticky bottom — pricing compact + CTA ─────
              Align(
                alignment: Alignment.bottomCenter,
                child: _StickyPricingBottom(
                  selected: _selected,
                  onSelect: _select,
                  onPurchase: () => _onTapSubscribe(context, ref, _selected),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _select(_Plan plan) {
    HapticFeedback.selectionClick();
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .track(
            AnalyticsEvent.paywallPlanSelected,
            properties: <String, Object>{
              'plan': plan.name,
              'product_id': plan.productId,
            },
          ),
    );
    setState(() => _selected = plan);
  }
}

// ─────────────────────────────────────────────────────────────────
// Hero : §2.3 Ember Accent + §2.4 Digital Display (Doto lockup)
// Une seule instance de chaque par écran — c'est ici.
// ─────────────────────────────────────────────────────────────────

class _EmberHeroLockup extends StatelessWidget {
  const _EmberHeroLockup();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: CalmRadius.xl2,
          cornerSmoothing: CalmRadius.smoothingFor(CalmRadius.xl2),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Ember radial mesh — la scène.
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.3, -0.2),
                  radius: 1.2,
                  colors: <Color>[
                    Color(0xFFFF5A1F),
                    Color(0xFFFF8C42),
                    Color(0xFFFFB067),
                    Color(0xFFFFB067),
                  ],
                  stops: <double>[0, 0.4, 0.8, 1],
                ),
              ),
            ),
            // Glass card flottante : le sujet.
            Center(
              child: Padding(
                padding: const EdgeInsets.all(CalmSpace.s6),
                child: GlassCard(
                  elevated: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: CalmSpace.s7,
                    vertical: CalmSpace.s6,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Eyebrow mono-type
                      Text(
                        'BEEDLE · PRO',
                        style: AppTypography.mono(
                          const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.5,
                            color: AppColors.neutral6,
                          ),
                        ),
                      ),
                      const Gap(CalmSpace.s3),
                      // Doto digital lockup — l'unique moment Doto de l'écran.
                      const CalmDigitalNumber(
                        value: 'PRO',
                        size: 44,
                        letterSpacing: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Bénéfice row — Lucide-style stroke icon + title + body
// ─────────────────────────────────────────────────────────────────

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CalmSpace.s5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.neutral8),
          const Gap(CalmSpace.s5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.neutral8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(CalmSpace.s1),
                Text(
                  body,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral6,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitDivider extends StatelessWidget {
  const _BenefitDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.neutral2);
  }
}

// ─────────────────────────────────────────────────────────────────
// Testimonials — carrousel horizontal mis en avant.
//
// Remplace l'ancien _SocialProof (une seule quote centrée, trop discret).
// Header fort + rating global en ligne, puis 5 cards scrollables qui
// débordent jusqu'au bord écran. La bande laisse clairement voir le
// début de la card suivante → invite au scroll sans flèche.
// ─────────────────────────────────────────────────────────────────

/// Hauteur réservée pour le bloc sticky bottom (pricing compact + CTA
/// + trust line). Sert à calculer le padding bottom du scroll pour que
/// le dernier item ne soit pas masqué.
const double _kStickyHeight = 244;

class _TestimonialsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CalmSpace.s7),
          child: Row(
            children: <Widget>[
              ...List<Widget>.generate(
                5,
                (int _) => const Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: AppColors.ember,
                  ),
                ),
              ),
              const Gap(CalmSpace.s3),
              Text(
                '4.8',
                style: AppTypography.mono(
                  const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral8,
                  ),
                ),
              ),
              const Gap(CalmSpace.s3),
              Text(
                '· 120 avis',
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.neutral6),
              ),
            ],
          ),
        ),
        const Gap(CalmSpace.s3),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CalmSpace.s7),
          child: Text(
            'Ils ont arrêté d\u2019oublier',
            style: textTheme.headlineSmall?.copyWith(
              color: AppColors.neutral8,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const Gap(CalmSpace.s5),
        const TestimonialCarousel(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sticky bottom — reste visible pendant le scroll.
//
// Compose : pills pricing horizontales (3 plans) + CTA + trust line.
// Glass.strong + blur σ24 pour que le contenu au-dessus soit visible
// par transparence (indique qu'on peut encore scroller).
// ─────────────────────────────────────────────────────────────────

class _StickyPricingBottom extends StatelessWidget {
  const _StickyPricingBottom({
    required this.selected,
    required this.onSelect,
    required this.onPurchase,
  });

  final _Plan selected;
  final ValueChanged<_Plan> onSelect;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.glassStrong,
            border: Border(
              top: BorderSide(color: AppColors.glassBorder),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            CalmSpace.s5,
            CalmSpace.s5,
            CalmSpace.s5,
            CalmSpace.s4 + safeBottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _CompactPricingPill(
                      plan: _Plan.yearly,
                      selected: selected == _Plan.yearly,
                      onTap: () => onSelect(_Plan.yearly),
                    ),
                  ),
                  const Gap(CalmSpace.s3),
                  Expanded(
                    child: _CompactPricingPill(
                      plan: _Plan.monthly,
                      selected: selected == _Plan.monthly,
                      onTap: () => onSelect(_Plan.monthly),
                    ),
                  ),
                  const Gap(CalmSpace.s3),
                  Expanded(
                    child: _CompactPricingPill(
                      plan: _Plan.lifetime,
                      selected: selected == _Plan.lifetime,
                      onTap: () => onSelect(_Plan.lifetime),
                    ),
                  ),
                ],
              ),
              const Gap(CalmSpace.s4),
              SquircleButton(
                label: _ctaLabelFor(selected),
                expand: true,
                onPressed: onPurchase,
              ),
              const Gap(CalmSpace.s3),
              Text(
                _trustLineFor(selected),
                textAlign: TextAlign.center,
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.neutral5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill compact pour le sticky bottom — résume une option en 3 lignes :
/// label, prix, sub (savings ou sans engagement). Sélection via border
/// ember 1.5px + fond glass.medium.
class _CompactPricingPill extends StatelessWidget {
  const _CompactPricingPill({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final _Plan plan;
  final bool selected;
  final VoidCallback onTap;

  String get _label {
    switch (plan) {
      case _Plan.yearly:
        return 'Annuel';
      case _Plan.monthly:
        return 'Mensuel';
      case _Plan.lifetime:
        return 'À vie';
    }
  }

  String get _price {
    switch (plan) {
      case _Plan.yearly:
        return '29,99 €';
      case _Plan.monthly:
        return '4,99 €';
      case _Plan.lifetime:
        return '79,99 €';
    }
  }

  String get _sub {
    switch (plan) {
      case _Plan.yearly:
        return '-50 %';
      case _Plan.monthly:
        return '/mois';
      case _Plan.lifetime:
        return 'une fois';
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final SmoothBorderRadius radius = SmoothBorderRadius(
      cornerRadius: CalmRadius.lg,
      cornerSmoothing: CalmRadius.smoothingFor(CalmRadius.lg),
    );
    final bool isYearly = plan == _Plan.yearly;
    final Color subColor =
        isYearly ? AppColors.ember : AppColors.neutral6;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: SmoothRectangleBorder(borderRadius: radius),
        child: AnimatedContainer(
          duration: CalmDuration.quick,
          curve: CalmCurves.standard,
          padding: const EdgeInsets.symmetric(
            vertical: CalmSpace.s4,
            horizontal: CalmSpace.s3,
          ),
          decoration: ShapeDecoration(
            color: selected ? AppColors.glassMedium : AppColors.glassSoft,
            shape: SmoothRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: selected
                    ? AppColors.ember.withValues(alpha: 0.65)
                    : AppColors.neutral3,
                width: selected ? 1.5 : 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _label,
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.neutral6,
                  letterSpacing: 0.5,
                ),
              ),
              const Gap(2),
              Text(
                _price,
                style: AppTypography.mono(
                  const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral8,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const Gap(2),
              Text(
                _sub,
                style: textTheme.labelSmall?.copyWith(
                  color: subColor,
                  fontWeight: isYearly ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Pricing card — glass.medium selected / glass.soft unselected
// ─────────────────────────────────────────────────────────────────

enum _Plan {
  yearly('beedle_pro_yearly'),
  monthly('beedle_pro_monthly'),
  lifetime('beedle_pro_lifetime');

  const _Plan(this.productId);
  final String productId;
}

String _ctaLabelFor(_Plan plan) {
  switch (plan) {
    case _Plan.yearly:
      return 'Essayer 7 jours';
    case _Plan.monthly:
      return 'Passer Pro · 4,99 €/mois';
    case _Plan.lifetime:
      return 'Acheter à vie · 79,99 €';
  }
}

String _trustLineFor(_Plan plan) {
  switch (plan) {
    case _Plan.yearly:
      return 'Annulable à tout moment. Paiement après l\u2019essai.';
    case _Plan.monthly:
      return 'Annulable à tout moment.';
    case _Plan.lifetime:
      return 'Paiement unique · aucune récurrence.';
  }
}

// ─────────────────────────────────────────────────────────────────
// Legal links — label.sm neutral.5
// ─────────────────────────────────────────────────────────────────

class _LegalLinks extends StatelessWidget {
  const _LegalLinks();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _legalLink(textTheme, 'CGV'),
        Text(
          ' · ',
          style: textTheme.labelSmall?.copyWith(color: AppColors.neutral4),
        ),
        _legalLink(textTheme, 'Confidentialité'),
      ],
    );
  }

  Widget _legalLink(TextTheme textTheme, String label) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: AppColors.neutral5,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Achat
// ─────────────────────────────────────────────────────────────────

/// Gate l'achat sur l'auth : si l'utilisateur est anonyme, on push
/// `AuthRoute(required: true)` et on retry l'achat au retour si signed-in.
///
/// Le [plan] sélectionné donne le productId App Store / Play Console ;
/// RevenueCat résout le package correspondant dans l'offering `default`.
Future<void> _onTapSubscribe(
  BuildContext context,
  WidgetRef ref,
  _Plan plan,
) async {
  final AnalyticsService analytics = ref.read(analyticsServiceProvider);
  AuthUserEntity? user = ref.read(currentUserProvider);
  if (user == null) {
    await context.router.push(AuthRoute(required: true));
    if (!context.mounted) return;
    user = ref.read(currentUserProvider);
    if (user == null) return;
  }
  try {
    await ref
        .read(subscriptionRepositoryProvider)
        .purchase(plan.productId);
    await analytics.track(
      AnalyticsEvent.subscribed,
      properties: <String, Object>{
        'plan': plan.name,
        'product_id': plan.productId,
        'source': 'standalone_paywall',
      },
    );
    if (context.mounted) unawaited(context.router.maybePop());
  } on Exception catch (e) {
    await analytics.track(
      AnalyticsEvent.subscriptionFailed,
      properties: <String, Object>{
        'plan': plan.name,
        'product_id': plan.productId,
        'reason': e.runtimeType.toString(),
      },
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.ink,
          behavior: SnackBarBehavior.floating,
          shape: StadiumBorder(),
          margin: EdgeInsets.all(CalmSpace.s5),
          content: Text(
            'Impossible de finaliser l\u2019achat.',
            style: TextStyle(color: AppColors.canvas),
          ),
        ),
      );
    }
  }
}
