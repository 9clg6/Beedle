import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/enum/subscription_tier.enum.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:beedle/features/paywall/presentation/screens/paywall.screen.dart' show PaywallScreen;
import 'package:beedle/features/paywall/presentation/widgets/testimonial_carousel.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_digital_number.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'dart:ui';

/// Écran 15 — Paywall onboarding (Beedle Pro).
///
/// Aligné visuellement sur [PaywallScreen] (design CalmSurface complet :
/// Aurora Warm via parent, Ember accent + Doto lockup hero, 5 bénéfices
/// Lucide-style, 3 pricing cards, CTA ink).
///
/// Différences avec le paywall principal :
///   • « Passer Free » visible en plus du restore (au lieu d'un simple close).
///   • Analytics `paywallShown` / `trialStarted` loggés.
///   • Fin de flow → `finishOnboarding()` + replace HomeRoute (pas un pop).
///
/// Voir `docs/PAYWALL_EXPERIMENTS.md` pour la liste des tests A/B en cours
/// et le plan de priorisation.
class OnboardingPaywallStep extends ConsumerStatefulWidget {
  const OnboardingPaywallStep({super.key});

  @override
  ConsumerState<OnboardingPaywallStep> createState() =>
      _OnboardingPaywallStepState();
}

enum _Plan {
  yearly('beedle_pro_yearly'),
  monthly('beedle_pro_monthly'),
  lifetime('beedle_pro_lifetime');

  const _Plan(this.productId);
  final String productId;
}

class _OnboardingPaywallStepState extends ConsumerState<OnboardingPaywallStep> {
  _Plan _selected = _Plan.yearly;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(analyticsServiceProvider).track(
            AnalyticsEvent.paywallShown,
            properties: const <String, Object>{'source': 'onboarding'},
          );
    });
  }

  Future<void> _finishToHome() async {
    await ref.read(onboardingViewModelProvider.notifier).finishOnboarding();
    if (!mounted) return;
    await context.router.replace(const HomeRoute());
  }

  void _select(_Plan plan) {
    HapticFeedback.selectionClick();
    setState(() => _selected = plan);
  }

  Future<void> _onSubscribe() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(subscriptionRepositoryProvider)
          .purchase(_selected.productId);
      await ref.read(analyticsServiceProvider).track(
            AnalyticsEvent.trialStarted,
            properties: <String, Object>{'product_id': _selected.productId},
          );
      await _finishToHome();
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.onboarding_ob15_error_purchase.tr()),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onContinueFree() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _finishToHome();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onRestore() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(subscriptionRepositoryProvider).restore();
      final SubscriptionSnapshotEntity snapshot = await ref
          .read(subscriptionRepositoryProvider)
          .load();
      if (snapshot.tier == SubscriptionTier.pro) {
        await ref
            .read(analyticsServiceProvider)
            .track(AnalyticsEvent.subscriptionRestored);
        await _finishToHome();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.onboarding_ob15_error_restore.tr()),
          ),
        );
      }
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.onboarding_ob15_error_restore.tr()),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Stack(
      children: <Widget>[
        // ───── Scrollable content ─────
        // Padding top = room for the floating close X. Bottom réserve la
        // hauteur du sticky (pricing + CTA + free + restore).
        ListView(
          padding: EdgeInsets.fromLTRB(
            0,
            CalmSpace.s9,
            0,
            _kStickyHeightOnboarding + MediaQuery.paddingOf(context).bottom,
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CalmSpace.s7),
              child: const _EmberHeroLockup(),
            ),
            const Gap(CalmSpace.s7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CalmSpace.s7),
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
                    'Scan IA sur 100 % de tes trouvailles, et des rappels '
                    'qui les ramènent aux bonnes heures.',
                    style:
                        textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
                  ),
                ],
              ),
            ),
            const Gap(CalmSpace.s7),
            _TestimonialsSection(),
            const Gap(CalmSpace.s7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CalmSpace.s7),
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
                      body: 'Retrouve une carte par son idée, pas ses mots.',
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
          ],
        ),

        // ───── Close X flottant en haut à droite ─────
        // Bouton de sortie rapide : trigge « Continuer en gratuit » (pas
        // de différence fonctionnelle vs le ghost du sticky, mais plus
        // accessible en immersive mode sans NavBar).
        Positioned(
          top: CalmSpace.s4,
          right: CalmSpace.s5,
          child: _CloseButton(onTap: _onContinueFree),
        ),

        // ───── Sticky bottom — pricing + CTA + free + restore ─────
        Align(
          alignment: Alignment.bottomCenter,
          child: _OnboardingStickyBottom(
            selected: _selected,
            busy: _busy,
            onSelect: _select,
            onPurchase: _onSubscribe,
            onContinueFree: _onContinueFree,
            onRestore: _onRestore,
          ),
        ),
      ],
    );
  }
}

/// Bouton close flottant — pill glass.soft + icône close inline.
/// Le même bouton sert pour le paywall onboarding ET le main paywall
/// (via `onTap: () => Navigator.pop(context)` côté main).
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.glassSoft,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neutral3),
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 18,
            color: AppColors.neutral8,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Testimonials — même section que paywall.screen.dart, dupliquée pour
// rester stable si l'onboarding et le paywall principal divergent.
// ─────────────────────────────────────────────────────────────────

/// Hauteur réservée pour le bloc sticky bottom en contexte onboarding.
/// Plus grand que paywall principal car on a un « continuer gratuit »
/// + « restaurer » en plus du CTA + pricing + trust line.
const double _kStickyHeightOnboarding = 320;

class _TestimonialsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
// Sticky bottom version onboarding — ajoute « Continuer gratuit » +
// « Restaurer un achat » en plus des 3 pricing pills + CTA trial.
// ─────────────────────────────────────────────────────────────────

class _OnboardingStickyBottom extends StatelessWidget {
  const _OnboardingStickyBottom({
    required this.selected,
    required this.busy,
    required this.onSelect,
    required this.onPurchase,
    required this.onContinueFree,
    required this.onRestore,
  });

  final _Plan selected;
  final bool busy;
  final ValueChanged<_Plan> onSelect;
  final VoidCallback onPurchase;
  final VoidCallback onContinueFree;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double safeBottom = MediaQuery.paddingOf(context).bottom;

    // Stack clipBehavior: none → la bulle "Seulement pour la beta" peut
    // déborder au-dessus du panel glass sans être clippée.
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        ClipRect(
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
                CalmSpace.s6,
                CalmSpace.s5,
                CalmSpace.s4 + safeBottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: _CompactPricingPill(
                          plan: _Plan.yearly,
                          selected: selected == _Plan.yearly,
                          onTap: () => onSelect(_Plan.yearly),
                          popular: true,
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
                    loading: busy,
                    onPressed: onPurchase,
                  ),
                  const Gap(CalmSpace.s3),
                  // Trust line mise en avant — icône check ember + texte
                  // plus dense pour reposer la garantie sans récurrence.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.shield_rounded,
                        size: 14,
                        color: AppColors.ember,
                      ),
                      const Gap(CalmSpace.s2),
                      Flexible(
                        child: Text(
                          _trustLineFor(selected),
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(CalmSpace.s4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        onPressed: onContinueFree,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          LocaleKeys.onboarding_ob15_cta_free.tr(),
                          style: textTheme.labelMedium
                              ?.copyWith(color: AppColors.neutral7),
                        ),
                      ),
                      Text(
                        '  ·  ',
                        style: textTheme.labelMedium
                            ?.copyWith(color: AppColors.neutral4),
                      ),
                      TextButton(
                        onPressed: onRestore,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          LocaleKeys.onboarding_ob15_cta_restore.tr(),
                          style: textTheme.labelMedium
                              ?.copyWith(color: AppColors.neutral6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ───── Bulle flottante « Seulement pour la beta » ─────
        // Positionnée au-dessus du panel sticky, alignée sur la colonne
        // du pill « À vie » (rightmost Expanded). Le tiers droit de la
        // largeur utile — on centre la bulle dessus via Align(+2/3) dans
        // un Row de 3 Expanded factices.
        Positioned(
          top: -24,
          left: CalmSpace.s5,
          right: CalmSpace.s5,
          child: Row(
            children: const <Widget>[
              Expanded(child: SizedBox.shrink()),
              Gap(CalmSpace.s3),
              Expanded(child: SizedBox.shrink()),
              Gap(CalmSpace.s3),
              Expanded(child: Center(child: _BetaFloatingBubble())),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bulle flottante ink avec queue pointant vers le pill « À vie ».
///
/// Dessinée en 2 parties : le corps rounded + un triangle qui pointe
/// vers le bas. Animation discrète d'un petit flotté vertical (±2px).
class _BetaFloatingBubble extends StatefulWidget {
  const _BetaFloatingBubble();

  @override
  State<_BetaFloatingBubble> createState() => _BetaFloatingBubbleState();
}

class _BetaFloatingBubbleState extends State<_BetaFloatingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (BuildContext _, Widget? child) {
        final double dy = (_float.value - 0.5) * 4; // ±2px
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CalmSpace.s4,
              vertical: CalmSpace.s2 + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(CalmRadius.pill),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Seulement pour la beta',
              style: AppTypography.mono(
                const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.canvas,
                  letterSpacing: 0.4,
                  height: 1.2,
                ),
              ),
            ),
          ),
          // Queue triangulaire pointant vers le bas
          CustomPaint(size: const Size(10, 6), painter: _BubbleTailPainter()),
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = AppColors.ink;
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Pill compact pour le sticky onboarding.
///
/// `popular: true` → badge "LE PLUS POPULAIRE" floattant par-dessus le
/// bord haut du pill, border mint (tertiary CalmSurface) quel que soit
/// l'état de sélection, glow discret pour l'attention.
class _CompactPricingPill extends StatelessWidget {
  const _CompactPricingPill({
    required this.plan,
    required this.selected,
    required this.onTap,
    this.popular = false,
  });

  final _Plan plan;
  final bool selected;
  final VoidCallback onTap;
  final bool popular;

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
        return '/an';
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
    // Border color logic :
    //  - popular: mint (tertiary) toujours visible → signale le hero plan
    //  - selected (non popular) : ember selection cue
    //  - idle : neutral.3 discret
    final Color borderColor = popular
        ? AppColors.mint
        : selected
            ? AppColors.ember.withValues(alpha: 0.65)
            : AppColors.neutral3;
    final double borderWidth = popular ? 2 : (selected ? 1.5 : 1);

    const Color subColor = AppColors.neutral6;

    final Widget pill = Material(
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
              side: BorderSide(color: borderColor, width: borderWidth),
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
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!popular) return pill;

    // Popular badge : flotte sur le bord haut du pill.
    // Clip.none pour que le badge déborde au-dessus du panel sticky.
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: <Widget>[
        pill,
        Positioned(
          top: -9,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: CalmSpace.s3,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(CalmRadius.pill),
            ),
            child: Text(
              'POPULAIRE',
              style: AppTypography.mono(
                const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: 0.8,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Helpers copy (partagés avec paywall.screen.dart logique)
// ─────────────────────────────────────────────────────────────────

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
// Ember hero + Doto lockup (§2.3 + §2.4 DESIGN.md)
// ─────────────────────────────────────────────────────────────────

/// Hero card BEEDLE · PRO avec animation shiny discrète.
///
/// Sweep d'une bande gradient blanc-alpha diagonale toutes les ~3 s.
/// Positionnée en overlay sur la card ember, clippée par le squircle
/// parent. Respecte CalmSurface §1.7 Motion : une seule moment
/// expressif par écran, durée grand, jamais de bounce ni pulse.
class _EmberHeroLockup extends StatefulWidget {
  const _EmberHeroLockup();

  @override
  State<_EmberHeroLockup> createState() => _EmberHeroLockupState();
}

class _EmberHeroLockupState extends State<_EmberHeroLockup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

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
            // Base : mesh Ember
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

            // Shiny sweep overlay
            AnimatedBuilder(
              animation: _shine,
              builder: (BuildContext _, Widget? _) {
                return IgnorePointer(
                  child: _ShinySweep(progress: _shine.value),
                );
              },
            ),

            // Glass card lockup
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

/// Overlay bande-gradient qui sweep diagonalement.
///
/// [progress] 0..1 → décale la bande de -1.5 largeur à +1.5 largeur.
/// 60% du cycle = pause off-screen, 40% = pass visible à l'écran.
class _ShinySweep extends StatelessWidget {
  const _ShinySweep({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    // Map progress : 0..0.4 → swipe across ; 0.4..1 → off-screen (pause).
    final bool onScreen = progress < 0.4;
    if (!onScreen) return const SizedBox.shrink();

    // Lerp position de -1.2 (hors-écran gauche) à +1.2 (hors-écran droite).
    final double t = progress / 0.4;
    final double alignmentX = -1.2 + (t * 2.4);

    return Align(
      alignment: Alignment(alignmentX, 0),
      child: FractionallySizedBox(
        widthFactor: 0.4,
        heightFactor: 1.4,
        child: Transform.rotate(
          angle: -0.35, // léger skew diagonal
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[
                  Color(0x00FFFFFF),
                  Color(0x33FFFFFF),
                  Color(0x66FFFFFF),
                  Color(0x33FFFFFF),
                  Color(0x00FFFFFF),
                ],
                stops: <double>[0, 0.3, 0.5, 0.7, 1],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Bénéfice row
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

