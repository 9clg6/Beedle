import 'package:freezed_annotation/freezed_annotation.dart';

part 'import.state.freezed.dart';

@Freezed(copyWith: true)
abstract class ImportState with _$ImportState {
  const factory ImportState({
    @Default(<String>[]) List<String> selectedPaths,
    @Default(false) bool isImporting,
    String? error,
  }) = _ImportState;

  factory ImportState.initial() => const ImportState();
}
