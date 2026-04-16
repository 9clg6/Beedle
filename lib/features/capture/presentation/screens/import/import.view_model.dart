import 'dart:async';

import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/core/providers/usecase_providers.dart';
import 'package:beedle/domain/entities/ingestion_job.entity.dart';
import 'package:beedle/domain/params/import_screenshot.param.dart';
import 'package:beedle/features/capture/presentation/screens/import/import.state.dart';
import 'package:beedle/foundation/exceptions/app_exceptions.dart';
import 'package:beedle/foundation/interfaces/results.usecases.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'import.view_model.g.dart';

@riverpod
class ImportViewModel extends _$ImportViewModel {
  @override
  ImportState build() => ImportState.initial();

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> files = await picker.pickMultiImage(
      imageQuality: 90,
      limit: 20,
    );
    if (files.isEmpty) return;
    state = state.copyWith(
      selectedPaths: files.map((XFile f) => f.path).toList(),
      error: null,
    );
  }

  /// Reset explicite du state — appelé par le screen après le pop de route
  /// pour nettoyer `selectedPaths` et revenir en `ImportPhase.idle`.
  void reset() {
    state = ImportState.initial();
  }

  /// Convertit une `Exception` brute en message utilisateur traduit.
  /// Les cas typés (ex: `AllDuplicatesException`) ont un rendu dédié ;
  /// sinon on fallback sur le générique pour ne pas exposer `toString()`.
  String _humanizeError(Exception e) {
    if (e is AllDuplicatesException) {
      return LocaleKeys.capture_import_all_duplicates.tr();
    }
    return LocaleKeys.common_error_generic.tr();
  }

  Future<void> confirmImport() async {
    if (state.selectedPaths.isEmpty) return;
    state = state.copyWith(phase: ImportPhase.importing, error: null);

    final ResultState<IngestionJobEntity> result = await ref
        .read(importScreenshotsUseCaseProvider)
        .execute(
          ImportScreenshotParam(filePaths: state.selectedPaths),
        );

    result.when(
      success: (_) {
        // Force le pipeline à traiter le job immédiatement (l'app est foreground).
        unawaited(ref.read(ingestionPipelineServiceProvider).processNext());
        // On passe en "launched" — l'écran observe cette phase pour afficher
        // le feedback "Digestion lancée" et déclencher la transition Hero.
        // Le reset (ImportState.initial()) n'est fait qu'après le pop côté UI
        // pour éviter que le pill Hero disparaisse avant la route transition.
        state = state.copyWith(phase: ImportPhase.launched);
      },
      failure: (Exception e) {
        state = state.copyWith(
          phase: ImportPhase.error,
          error: _humanizeError(e),
        );
      },
    );
  }
}
