import 'package:freezed_annotation/freezed_annotation.dart';

part 'import.state.freezed.dart';

/// Phases du flow d'import screenshots → digestion.
///
/// - [idle]     : rien en cours — soit on n'a pas sélectionné, soit on vient
///                de reset.
/// - [importing]: le use case `ImportScreenshotsUseCase` est en cours
///                d'exécution (création du job en base + copie des fichiers).
/// - [launched] : le job a été enqueue avec succès — on affiche un feedback
///                de confirmation ("Digestion lancée") puis on déclenche la
///                transition Hero vers la Home.
/// - [error]    : une exception a été levée pendant le use case — on laisse
///                l'utilisateur corriger (ex: re-tenter) sans pop.
enum ImportPhase { idle, importing, launched, error }

@Freezed(copyWith: true)
abstract class ImportState with _$ImportState {
  const factory ImportState({
    @Default(<String>[]) List<String> selectedPaths,
    @Default(ImportPhase.idle) ImportPhase phase,
    String? error,
  }) = _ImportState;

  factory ImportState.initial() => const ImportState();
}
