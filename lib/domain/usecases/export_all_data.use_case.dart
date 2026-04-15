import 'package:beedle/foundation/interfaces/future.usecases.dart';

abstract interface class DataExportService {
  /// Retourne le JSON sérialisé des données user (Cards + metadata).
  Future<String> exportAsJson();
}

final class ExportAllDataUseCase extends FutureUseCase<String> {
  ExportAllDataUseCase({required DataExportService dataExportService})
      : _service = dataExportService;

  final DataExportService _service;

  @override
  Future<String> invoke() => _service.exportAsJson();
}
