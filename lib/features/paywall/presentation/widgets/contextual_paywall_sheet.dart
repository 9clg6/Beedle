import 'package:auto_route/auto_route.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Raisons pour lesquelles le user voit un paywall contextuel.
///
/// Chaque raison a son propre wording — on ne montre jamais un paywall
/// générique. Le gate doit toujours rappeler ce que le user essayait
/// de faire, et pourquoi c'est réservé au Pro.
enum ContextualPaywallReason {
  /// Quota mensuel de scans atteint (15/15).
  scanQuotaReached,

  /// Recherche sémantique tap sur Free.
  semanticSearch,

  /// Export Notion / Obsidian / Markdown.
  export,

  /// Sync multi-device.
  sync,

  /// Auto-tags / résumés IA sur les cartes déjà muettes.
  enrichExisting,

  /// Rappels adaptatifs (timing + regroupement).
  adaptiveReminders,
}

extension _ReasonCopy on ContextualPaywallReason {
  IconData get icon {
    switch (this) {
      case ContextualPaywallReason.scanQuotaReached:
        return Icons.auto_awesome_rounded;
      case ContextualPaywallReason.semanticSearch:
        return Icons.travel_explore_rounded;
      case ContextualPaywallReason.export:
        return Icons.ios_share_rounded;
      case ContextualPaywallReason.sync:
        return Icons.devices_rounded;
      case ContextualPaywallReason.enrichExisting:
        return Icons.auto_fix_high_rounded;
      case ContextualPaywallReason.adaptiveReminders:
        return Icons.notifications_active_rounded;
    }
  }

  String get title {
    switch (this) {
      case ContextualPaywallReason.scanQuotaReached:
        return 'Tes prochaines cartes\nresteraient muettes';
      case ContextualPaywallReason.semanticSearch:
        return 'La recherche par le sens\nest Pro';
      case ContextualPaywallReason.export:
        return 'L\u2019export est Pro';
      case ContextualPaywallReason.sync:
        return 'La sync multi-device\nest Pro';
      case ContextualPaywallReason.enrichExisting:
        return 'Faire chanter une carte\nest Pro';
      case ContextualPaywallReason.adaptiveReminders:
        return 'Les rappels adaptatifs\nsont Pro';
    }
  }

  String body(int? quota) {
    switch (this) {
      case ContextualPaywallReason.scanQuotaReached:
        return 'Tu as utilisé tes ${quota ?? 15} scans IA du mois. '
            'Passe Pro pour scanner sans limite — ou reviens le 1er du mois.';
      case ContextualPaywallReason.semanticSearch:
        return 'Retrouve une carte par son idée, pas ses mots. '
            'Débloque les embeddings et 4 autres sortilèges.';
      case ContextualPaywallReason.export:
        return 'Ta veille, portable : Notion, Obsidian, Markdown. '
            'Passe Pro pour exporter quand tu veux.';
      case ContextualPaywallReason.sync:
        return 'iPhone, iPad, Android — tes cartes te suivent partout. '
            'Disponible sur le plan Pro.';
      case ContextualPaywallReason.enrichExisting:
        return 'OCR, auto-tags, résumés IA sur toutes tes cartes existantes. '
            'Passe Pro pour faire chanter ta bibliothèque entière.';
      case ContextualPaywallReason.adaptiveReminders:
        return 'Le bon rappel, au bon moment, regroupé par thème. '
            'Les rappels intelligents arrivent avec Pro.';
    }
  }
}

/// Ouvre le bottom sheet paywall contextuel.
///
/// Usage côté feature :
/// ```dart
/// final bool didUpgrade = await showContextualPaywall(
///   context,
///   reason: ContextualPaywallReason.scanQuotaReached,
///   quotaLimit: 15,
/// );
/// if (didUpgrade) { /* retry feature */ }
/// ```
Future<bool> showContextualPaywall(
  BuildContext context, {
  required ContextualPaywallReason reason,
  int? quotaLimit,
}) async {
  final bool? result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.ink.withValues(alpha: 0.24),
    shape: SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius.only(
        topLeft: SmoothRadius(
          cornerRadius: CalmRadius.xl3,
          cornerSmoothing: CalmRadius.smoothingFor(CalmRadius.xl3),
        ),
        topRight: SmoothRadius(
          cornerRadius: CalmRadius.xl3,
          cornerSmoothing: CalmRadius.smoothingFor(CalmRadius.xl3),
        ),
      ),
    ),
    builder: (BuildContext ctx) => _ContextualPaywallSheet(
      reason: reason,
      quotaLimit: quotaLimit,
    ),
  );
  return result ?? false;
}

class _ContextualPaywallSheet extends ConsumerWidget {
  const _ContextualPaywallSheet({required this.reason, this.quotaLimit});

  final ContextualPaywallReason reason;
  final int? quotaLimit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final SmoothBorderRadius topRadius = SmoothBorderRadius.only(
      topLeft: SmoothRadius(
        cornerRadius: CalmRadius.xl3,
        cornerSmoothing: CalmRadius.smoothingFor(CalmRadius.xl3),
      ),
      topRight: SmoothRadius(
        cornerRadius: CalmRadius.xl3,
        cornerSmoothing: CalmRadius.smoothingFor(CalmRadius.xl3),
      ),
    );

    return Container(
      decoration: ShapeDecoration(
        color: AppColors.glassStrong,
        shape: SmoothRectangleBorder(borderRadius: topRadius),
      ),
      padding: EdgeInsets.fromLTRB(
        CalmSpace.s7,
        CalmSpace.s3,
        CalmSpace.s7,
        CalmSpace.s7 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Grab handle 36×4 neutral.4, 8px from top
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral4,
                borderRadius: BorderRadius.circular(CalmRadius.pill),
              ),
            ),
          ),
          const Gap(CalmSpace.s7),

          // Icon 32px
          Icon(reason.icon, size: 32, color: AppColors.neutral8),
          const Gap(CalmSpace.s5),

          // Titre
          Text(
            reason.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.neutral8,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const Gap(CalmSpace.s4),

          // Body
          Text(
            reason.body(quotaLimit),
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.neutral6,
              height: 1.5,
            ),
          ),
          const Gap(CalmSpace.s7),

          // Pricing summary one-liner
          _InlinePricing(),
          const Gap(CalmSpace.s6),

          // CTA primary ink
          SquircleButton(
            label: 'Essayer 7 jours',
            expand: true,
            onPressed: () async {
              Navigator.of(context).pop(false);
              // Redirige vers le plein paywall pour finaliser l'achat.
              await context.router.push(const PaywallRoute());
            },
          ),
          const Gap(CalmSpace.s3),

          // Ghost dismiss
          SquircleButton(
            label: 'Plus tard',
            variant: SquircleButtonVariant.ghost,
            expand: true,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

class _InlinePricing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CalmSpace.s6,
        vertical: CalmSpace.s5,
      ),
      decoration: ShapeDecoration(
        color: AppColors.glassSoft,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: CalmRadius.xl,
            cornerSmoothing: CalmRadius.smoothingFor(CalmRadius.xl),
          ),
          side: const BorderSide(color: AppColors.neutral3),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.workspace_premium_rounded,
            size: 20,
            color: AppColors.ember,
          ),
          const Gap(CalmSpace.s4),
          Expanded(
            child: Text(
              'Annuel · 29,99 € · économise 50 %',
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.neutral8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '2,49 €/mo',
            style: textTheme.bodySmall?.copyWith(color: AppColors.neutral6),
          ),
        ],
      ),
    );
  }
}
