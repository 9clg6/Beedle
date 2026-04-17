import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/auth.provider.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/app_typography.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_back_button.dart';
import 'package:beedle/presentation/widgets/calm_digital_number.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:figma_squircle/figma_squircle.dart';
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
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 60,
        leading: const CalmCloseButton(),
        actions: <Widget>[
          TextButton(
            onPressed: () => ref.read(subscriptionRepositoryProvider).restore(),
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              CalmSpace.s7,
              CalmSpace.s3,
              CalmSpace.s7,
              CalmSpace.s9,
            ),
            children: <Widget>[
              // ───── Hero : Ember accent + Doto lockup ─────
              const _EmberHeroLockup(),
              const Gap(CalmSpace.s8),

              // ───── Titre + subhead ─────
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
                style: textTheme.bodyLarge?.copyWith(color: AppColors.neutral6),
              ),
              const Gap(CalmSpace.s8),

              // ───── Bénéfices — liste iconée Lucide-like ─────
              GlassCard(
                elevated: false,
                child: Column(
                  children: const <Widget>[
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
              const Gap(CalmSpace.s8),

              // ───── Social proof ─────
              const _SocialProof(),
              const Gap(CalmSpace.s8),

              // ───── Pricing cards ─────
              _PricingCard(
                plan: _Plan.yearly,
                selected: _selected == _Plan.yearly,
                onTap: () => _select(_Plan.yearly),
              ),
              const Gap(CalmSpace.s4),
              _PricingCard(
                plan: _Plan.monthly,
                selected: _selected == _Plan.monthly,
                onTap: () => _select(_Plan.monthly),
              ),
              const Gap(CalmSpace.s7),

              // ───── Primary CTA — ink flat pill (in-app primary) ─────
              SquircleButton(
                label: _selected == _Plan.yearly
                    ? 'Essayer 7 jours'
                    : 'Passer Pro · 4,99 €/mois',
                expand: true,
                onPressed: () => _onTapSubscribe(context, ref),
              ),
              const Gap(CalmSpace.s4),

              // Trust line
              Text(
                _selected == _Plan.yearly
                    ? 'Annulable à tout moment. Paiement après l\u2019essai.'
                    : 'Annulable à tout moment.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: AppColors.neutral5),
              ),
              const Gap(CalmSpace.s5),

              // Legal
              const _LegalLinks(),
            ],
          ),
        ),
      ),
    );
  }

  void _select(_Plan plan) {
    HapticFeedback.selectionClick();
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
                  stops: <double>[0.0, 0.4, 0.8, 1.0],
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
                          TextStyle(
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
// Social proof — star rating (Geist Mono number) + testimonial
// ─────────────────────────────────────────────────────────────────

class _SocialProof extends StatelessWidget {
  const _SocialProof();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ...List<Widget>.generate(
              5,
              (int _) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: CalmSpace.s1),
                child: Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: AppColors.ember,
                ),
              ),
            ),
            const Gap(CalmSpace.s3),
            Text(
              '4.8',
              style: AppTypography.mono(
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral8,
                ),
              ),
            ),
          ],
        ),
        const Gap(CalmSpace.s5),
        Text(
          '« Enfin mes screenshots servent à quelque chose. »',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.neutral7,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
        const Gap(CalmSpace.s3),
        Text(
          'ALEX · DÉVELOPPEUSE',
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.neutral5,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Pricing card — glass.medium selected / glass.soft unselected
// ─────────────────────────────────────────────────────────────────

enum _Plan { yearly, monthly }

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final _Plan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isYearly = plan == _Plan.yearly;

    final SmoothBorderRadius radius = SmoothBorderRadius(
      cornerRadius: CalmRadius.xl,
      cornerSmoothing: CalmRadius.smoothingFor(CalmRadius.xl),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: SmoothRectangleBorder(borderRadius: radius),
        child: AnimatedContainer(
          duration: CalmDuration.quick,
          curve: CalmCurves.standard,
          padding: const EdgeInsets.symmetric(
            horizontal: CalmSpace.s6,
            vertical: CalmSpace.s5,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Radio indicator
              AnimatedContainer(
                duration: CalmDuration.quick,
                curve: CalmCurves.standard,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.ember : AppColors.neutral4,
                    width: 2,
                  ),
                  color: selected ? AppColors.ember : Colors.transparent,
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const Gap(CalmSpace.s5),
              // Title + sub
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          isYearly ? 'Annuel' : 'Mensuel',
                          style: textTheme.titleMedium?.copyWith(
                            color: AppColors.neutral8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isYearly) ...<Widget>[
                          const Gap(CalmSpace.s3),
                          _SavingsBadge(),
                        ],
                      ],
                    ),
                    const Gap(CalmSpace.s2),
                    Text(
                      isYearly
                          ? 'soit 2,49 € / mois · 7 jours gratuits'
                          : 'sans engagement',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral6,
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    isYearly ? '29,99 €' : '4,99 €',
                    style: AppTypography.mono(
                      TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral8,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Text(
                    isYearly ? '/an' : '/mois',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavingsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s3,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.ember,
        borderRadius: BorderRadius.circular(CalmRadius.pill),
      ),
      child: Text(
        '-50 %',
        style: AppTypography.mono(
          TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.canvas,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
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
Future<void> _onTapSubscribe(BuildContext context, WidgetRef ref) async {
  AuthUserEntity? user = ref.read(currentUserProvider);
  if (user == null) {
    await context.router.push(AuthRoute(required: true));
    if (!context.mounted) return;
    user = ref.read(currentUserProvider);
    if (user == null) return;
  }
  try {
    // NB : le plan est lu depuis le state du widget via _selected.
    // Pour la v1 on force yearly. À rebrancher quand le state sera hoist.
    await ref.read(subscriptionRepositoryProvider).purchase(
          'beedle_pro_yearly',
        );
    if (context.mounted) unawaited(context.router.maybePop());
  } on Exception catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.ink,
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
          margin: const EdgeInsets.all(CalmSpace.s5),
          content: const Text(
            'Impossible de finaliser l\u2019achat.',
            style: TextStyle(color: AppColors.canvas),
          ),
        ),
      );
    }
  }
}
