import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:beedle/features/capture/presentation/screens/import/import.state.dart';
import 'package:beedle/features/capture/presentation/screens/import/import.view_model.dart';
import 'package:beedle/features/home/presentation/widgets/upload_progress_card.dart';
import 'package:beedle/features/paywall/presentation/scan_gate.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_back_button.dart';
import 'package:beedle/presentation/widgets/calm_empty_state.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Délai entre l'affichage du pill de progression (phase=launched) et le
/// pop de route vers la Home. Laisse juste le temps de voir le pill
/// se poser, puis Flutter anime la transition Hero via la route Cupertino.
const Duration _kLaunchedDisplayDelay = Duration(milliseconds: 300);

@RoutePage()
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _popScheduled = false;

  @override
  Widget build(BuildContext context) {
    final ImportState state = ref.watch(importViewModelProvider);
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Observe la transition vers `launched` : déclenche le pop différé
    // une seule fois pour laisser la Hero animation se jouer.
    ref.listen<ImportState>(importViewModelProvider, (
      ImportState? previous,
      ImportState next,
    ) {
      if (next.phase == ImportPhase.launched && !_popScheduled) {
        _popScheduled = true;
        Timer(_kLaunchedDisplayDelay, () {
          if (!mounted) return;
          unawaited(context.router.maybePop());
          // Reset différé pour ne pas faire disparaître le pill Hero avant
          // la fin de la transition de route.
          Future<void>.delayed(const Duration(milliseconds: 50), () {
            if (!mounted) return;
            ref.read(importViewModelProvider.notifier).reset();
          });
        });
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leadingWidth: 60,
        leading: const CalmCloseButton(),
        title: Text(
          LocaleKeys.capture_import_title.tr(),
          style: textTheme.titleLarge,
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(CalmSpace.s6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: state.selectedPaths.isEmpty
                      ? CalmEmptyState(
                          digitalGlyph: '+++',
                          title: LocaleKeys.capture_import_cta.tr(),
                          body:
                              'Sélectionne des screenshots depuis ta '
                              'pellicule. Beedle les digère en fiches.',
                        )
                      : _ImageGrid(paths: state.selectedPaths),
                ),
                if (state.error != null) ...<Widget>[
                  Text(
                    state.error!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                  const Gap(CalmSpace.s3),
                ],
                _ImportActionArea(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Zone actionable du bas de l'ImportScreen — swap entre le bouton
/// « Continuer » (standard) et le `UploadProgressPill` (Hero source) une fois
/// le job enqueued. Animation fade+scale entre les deux, puis pop de route.
class _ImportActionArea extends ConsumerWidget {
  const _ImportActionArea({required this.state});
  final ImportState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool showPill = state.phase == ImportPhase.launched;
    return AnimatedSwitcher(
      duration: CalmDuration.standard,
      switchInCurve: CalmCurves.standard,
      switchOutCurve: CalmCurves.standard,
      transitionBuilder: (Widget child, Animation<double> anim) =>
          FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(anim),
              child: child,
            ),
          ),
      child: showPill
          ? Align(
              key: const ValueKey<String>('import-pill'),
              child: UploadProgressPill(count: state.selectedPaths.length),
            )
          : SquircleButton(
              key: const ValueKey<String>('import-button'),
              label: state.selectedPaths.isEmpty
                  ? LocaleKeys.capture_import_cta.tr()
                  : LocaleKeys.common_action_continue.tr(),
              icon: state.selectedPaths.isEmpty
                  ? Icons.photo_library_outlined
                  : Icons.arrow_forward_rounded,
              expand: true,
              loading: state.phase == ImportPhase.importing,
              onPressed: () async {
                if (state.selectedPaths.isEmpty) {
                  await ref.read(importViewModelProvider.notifier).pickImages();
                  return;
                }
                // Gate quota scan IA AVANT d'enqueuer le job.
                // Si le user free a atteint sa limite mensuelle, le
                // bottom sheet paywall contextuel s'ouvre — l'import est
                // silencieusement annulé jusqu'à upgrade ou mois suivant.
                final bool allowed =
                    await ScanGate.of(ref).requestPermission(context);
                if (!allowed) return;
                await ref
                    .read(importViewModelProvider.notifier)
                    .confirmImport();
              },
            ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.paths});
  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: CalmSpace.s6),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: CalmSpace.s3,
        crossAxisSpacing: CalmSpace.s3,
      ),
      itemCount: paths.length,
      itemBuilder: (BuildContext context, int i) {
        final SmoothRectangleBorder shape = SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: CalmRadius.lg,
            cornerSmoothing: 0.5,
          ),
          side: const BorderSide(color: AppColors.neutral3),
        );
        return ClipPath(
          clipper: ShapeBorderClipper(shape: shape),
          child: DecoratedBox(
            decoration: ShapeDecoration(shape: shape),
            child: Image.file(File(paths[i]), fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
