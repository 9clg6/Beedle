import 'dart:async';
import 'dart:ui';

import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/domain/repositories/ingestion_job.repository.dart';
import 'package:beedle/features/home/presentation/providers/upload_display_state.provider.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Tag Hero partagé entre l'`UploadProgressPill` (ImportScreen) et
/// l'`UploadProgressCard` (HomeScreen). Quand l'utilisateur tape sur
/// « Continuer » puis retourne à la Home, le pill s'envole et morphe en card.
const String kUploadProgressHeroTag = 'beedle.upload.progress';

/// Card persistante affichée en haut de la HomeScreen, au-dessus de la
/// TerminalCard. Remplace à la fois la SnackBar success de l'ancien flow
/// et le petit banner `IngestionStatusBanner`. Design : CalmSurface Liquid
/// Glass (§ DESIGN.md §4 cards + §8 semantic tokens).
///
/// L'état affiché est dérivé de `uploadDisplayStateProvider` — voir le doc
/// de la sealed class `UploadDisplayState` pour les règles de priorité.
class UploadProgressCard extends ConsumerWidget {
  const UploadProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UploadDisplayState> asyncState = ref.watch(
      uploadDisplayStateProvider,
    );
    final UploadDisplayState state =
        asyncState.value ?? const UploadDisplayIdle();

    return AnimatedSwitcher(
      duration: CalmDuration.standard,
      switchInCurve: CalmCurves.standard,
      switchOutCurve: CalmCurves.standard,
      child: switch (state) {
        UploadDisplayIdle() => const SizedBox.shrink(
          key: ValueKey<String>('upload-idle'),
        ),
        UploadDisplayActive(:final int count) => Hero(
          tag: kUploadProgressHeroTag,
          key: const ValueKey<String>('upload-active'),
          flightShuttleBuilder: _heroShuttle,
          child: _UploadCardShell(
            variant: _CardVariant.active,
            icon: const _EmberSpinner(),
            title: LocaleKeys.home_upload_active_title.tr(),
            subtitle: count == 1
                ? LocaleKeys.home_upload_active_subtitle_single.tr()
                : LocaleKeys.home_upload_active_subtitle_multiple.tr(
                    namedArgs: <String, String>{'count': '$count'},
                  ),
            trailing: const _ActiveCancelButton(),
          ),
        ),
        UploadDisplayFailed(
          :final List<String> jobUuids,
          :final String errorMessage,
        ) =>
          _UploadCardShell(
            key: const ValueKey<String>('upload-failed'),
            variant: _CardVariant.failed,
            icon: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.danger,
              size: 20,
            ),
            title: LocaleKeys.home_upload_failed_title.tr(),
            subtitle: errorMessage,
            trailing: _FailedActions(jobUuids: jobUuids),
          ),
        UploadDisplaySuccess(:final String cardTitle) => _UploadCardShell(
          key: const ValueKey<String>('upload-success'),
          variant: _CardVariant.success,
          icon: const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 20,
          ),
          title: LocaleKeys.home_upload_success_title.tr(),
          subtitle: cardTitle,
        ),
      },
    );
  }
}

/// Variante compacte du card — utilisée comme Hero source sur l'ImportScreen
/// une fois le job enqueue avec succès. S'envole vers la Home où le `Hero`
/// destination (`UploadProgressCard` en état active) prend le relais.
class UploadProgressPill extends StatelessWidget {
  const UploadProgressPill({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: kUploadProgressHeroTag,
      flightShuttleBuilder: _heroShuttle,
      child: _UploadCardShell(
        variant: _CardVariant.active,
        compact: true,
        icon: const _EmberSpinner(),
        title: LocaleKeys.home_upload_active_title.tr(),
        subtitle: count == 1
            ? LocaleKeys.home_upload_active_subtitle_single.tr()
            : LocaleKeys.home_upload_active_subtitle_multiple.tr(
                namedArgs: <String, String>{'count': '$count'},
              ),
      ),
    );
  }
}

// ===========================================================================
// Internals
// ===========================================================================

enum _CardVariant { active, failed, success }

/// Builder du Hero en vol : interpole le radius & padding entre le pill
/// compact (source, ImportScreen) et la card pleine (dest, HomeScreen).
/// La morph se fait sur la durée native de la route (~350ms Cupertino).
Widget _heroShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final Widget toHero = toHeroContext.widget;
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      return Material(
        color: Colors.transparent,
        child: toHero,
      );
    },
  );
}

/// Shell partagé entre les 3 variantes — gère la squircle shape, le
/// background color mappé à la variante et les transitions internes.
class _UploadCardShell extends StatelessWidget {
  const _UploadCardShell({
    required this.variant,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.compact = false,
    super.key,
  });

  final _CardVariant variant;
  final Widget icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  /// Variante pill compacte pour le Hero source (ImportScreen).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final (Color background, Color border) = switch (variant) {
      _CardVariant.active => (
        isDark ? AppColors.glassDarkMedium : AppColors.glassMedium,
        isDark ? AppColors.glassDarkBorder : AppColors.glassBorder,
      ),
      _CardVariant.failed => (
        AppColors.danger.withValues(alpha: 0.06),
        AppColors.danger.withValues(alpha: 0.28),
      ),
      _CardVariant.success => (
        AppColors.success.withValues(alpha: 0.06),
        AppColors.success.withValues(alpha: 0.28),
      ),
    };

    final double radius = compact ? CalmRadius.pill : CalmRadius.xl2;
    final double smoothing = compact ? 0 : 0.6;
    final EdgeInsets padding = compact
        ? const EdgeInsets.symmetric(
            horizontal: CalmSpace.s5,
            vertical: CalmSpace.s4,
          )
        : const EdgeInsets.all(CalmSpace.s5);

    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(
        cornerRadius: radius,
        cornerSmoothing: smoothing,
      ),
      side: BorderSide(color: border),
    );

    final Widget content = ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: CalmBlur.floating,
          sigmaY: CalmBlur.floating,
        ),
        child: AnimatedContainer(
          duration: CalmDuration.quick,
          curve: CalmCurves.standard,
          decoration: ShapeDecoration(
            shape: shape,
            color: background,
            shadows: compact ? const <BoxShadow>[] : CalmShadows.sm,
          ),
          padding: padding,
          child: Row(
            children: <Widget>[
              SizedBox(width: 20, height: 20, child: Center(child: icon)),
              const Gap(CalmSpace.s4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.neutral8Dark
                            : AppColors.neutral8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!compact) ...<Widget>[
                      const Gap(CalmSpace.s1),
                      AnimatedSwitcher(
                        duration: CalmDuration.quick,
                        child: Text(
                          subtitle,
                          key: ValueKey<String>(subtitle),
                          style: textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.neutral6Dark
                                : AppColors.neutral6,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const Gap(CalmSpace.s3),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );

    return content;
  }
}

/// Spinner 16×16 ember — signature pour l'état active. Garde le même strokeWidth
/// que le legacy `IngestionStatusBanner` pour cohérence visuelle.
class _EmberSpinner extends StatelessWidget {
  const _EmberSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        color: AppColors.ember,
      ),
    );
  }
}

/// Trailing widget pour l'état failed : bouton "Réessayer" en pill mint
/// compact + IconButton "X" pour dismiss. Les actions sont câblées
/// directement sur le repository / provider — pas de callback exposé.
class _FailedActions extends ConsumerWidget {
  const _FailedActions({required this.jobUuids});
  final List<String> jobUuids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _MiniActionButton(
          label: LocaleKeys.home_upload_failed_retry.tr(),
          onTap: () {
            // Feedback UI immédiat : on retire les jobs du set dismissed
            // (ils passent de rouge à actif via le watchActiveAndFailed).
            ref.read(dismissedFailedJobsProvider.notifier).restore(jobUuids);
            // Retry en fire-and-forget — on NE bloque PAS l'UI.
            // `retryFailed()` remet les jobs en queued puis le pipeline
            // reprend dans son worker loop. Les erreurs éventuelles
            // sont re-persistées sur le job (status=failed, lastError),
            // ce qui ramène naturellement la card en état failed.
            final IngestionJobRepository repo = ref.read(
              ingestionJobRepositoryProvider,
            );
            unawaited(repo.retryFailed());
          },
        ),
        const Gap(CalmSpace.s2),
        Semantics(
          label: LocaleKeys.home_upload_failed_dismiss_a11y.tr(),
          button: true,
          child: InkResponse(
            onTap: () {
              ref.read(dismissedFailedJobsProvider.notifier).dismiss(jobUuids);
            },
            radius: 20,
            child: const Padding(
              padding: EdgeInsets.all(CalmSpace.s2),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.neutral6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Trailing widget pour l'état active : icône X qui annule tous les jobs
/// actifs (queued/processing) via `deleteActiveJobs()`. Le stream ObjectBox
/// notifie immédiatement, la card bascule en `idle`. Si un job était en cours
/// de traitement côté pipeline, le check `getByUuid` du pipeline détectera
/// son absence et abortera sans créer de card.
class _ActiveCancelButton extends ConsumerWidget {
  const _ActiveCancelButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: LocaleKeys.home_upload_active_cancel_a11y.tr(),
      button: true,
      child: InkResponse(
        onTap: () {
          final IngestionJobRepository repo = ref.read(
            ingestionJobRepositoryProvider,
          );
          // Fire-and-forget : la suppression ObjectBox est quasi instantanée,
          // pas besoin de loading state. On n'attend pas pour ne pas bloquer
          // le thread UI si jamais la query prend plus longtemps.
          unawaited(repo.deleteActiveJobs());
        },
        radius: 20,
        child: const Padding(
          padding: EdgeInsets.all(CalmSpace.s2),
          child: Icon(
            Icons.close_rounded,
            size: 18,
            color: AppColors.neutral6,
          ),
        ),
      ),
    );
  }
}

/// Mini bouton pill mint pour le retry — plus compact que `SquircleButton`
/// pour tenir dans le trailing de la card failed.
class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SmoothRectangleBorder shape = SmoothRectangleBorder(
      borderRadius: SmoothBorderRadius(cornerRadius: CalmRadius.pill),
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: CalmSpace.s4,
            vertical: CalmSpace.s2,
          ),
          decoration: ShapeDecoration(
            shape: shape,
            color: AppColors.mint,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
