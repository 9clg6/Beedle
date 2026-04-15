import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:beedle/features/capture/presentation/screens/import/import.state.dart';
import 'package:beedle/features/capture/presentation/screens/import/import.view_model.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_empty_state.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

@RoutePage()
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importViewModelProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.router.maybePop(),
          icon: const Icon(Icons.close_rounded, color: AppColors.neutral8),
        ),
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
                          body: 'Sélectionne des screenshots depuis ta '
                              'pellicule. Beedle les digère en fiches.',
                        )
                      : _ImageGrid(paths: state.selectedPaths),
                ),
                if (state.error != null) ...<Widget>[
                  Text(
                    state.error!,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.danger),
                  ),
                  const Gap(CalmSpace.s3),
                ],
                SquircleButton(
                  label: state.selectedPaths.isEmpty
                      ? LocaleKeys.capture_import_cta.tr()
                      : LocaleKeys.common_action_continue.tr(),
                  icon: state.selectedPaths.isEmpty
                      ? Icons.photo_library_outlined
                      : Icons.arrow_forward_rounded,
                  expand: true,
                  loading: state.isImporting,
                  onPressed: () async {
                    if (state.selectedPaths.isEmpty) {
                      await ref
                          .read(importViewModelProvider.notifier)
                          .pickImages();
                    } else {
                      await ref
                          .read(importViewModelProvider.notifier)
                          .confirmImport();
                      if (mounted) context.router.maybePop();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
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
      itemBuilder: (context, i) {
        final shape = SmoothRectangleBorder(
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
