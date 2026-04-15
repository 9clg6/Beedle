import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/core/providers/usecase_providers.dart';
import 'package:beedle/domain/entities/ingestion_job.entity.dart';
import 'package:beedle/domain/params/import_screenshot.param.dart';
import 'package:beedle/features/capture/presentation/screens/import/import.state.dart';
import 'package:beedle/foundation/interfaces/results.usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'import.view_model.g.dart';

@riverpod
class ImportViewModel extends _$ImportViewModel {
  @override
  ImportState build() => ImportState.initial();

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 90, limit: 20);
    if (files.isEmpty) return;
    state = state.copyWith(selectedPaths: files.map((f) => f.path).toList(), error: null);
  }

  Future<void> confirmImport() async {
    if (state.selectedPaths.isEmpty) return;
    state = state.copyWith(isImporting: true, error: null);

    final ResultState<IngestionJobEntity> result = await ref.read(importScreenshotsUseCaseProvider).execute(
          ImportScreenshotParam(filePaths: state.selectedPaths),
        );

    result.when(
      success: (_) {
        // Force le pipeline à traiter le job immédiatement (l'app est foreground).
        unawaited(ref.read(ingestionPipelineServiceProvider).processNext());
        state = ImportState.initial();
      },
      failure: (e) {
        state = state.copyWith(isImporting: false, error: e.toString());
      },
    );
  }
}

void unawaited(Future<void> future) {}
