import 'dart:io';

import 'package:beedle/domain/entities/ingestion_job.entity.dart';
import 'package:beedle/domain/entities/screenshot.entity.dart';
import 'package:beedle/domain/params/import_screenshot.param.dart';
import 'package:beedle/domain/repositories/ingestion_job.repository.dart';
import 'package:beedle/domain/repositories/screenshot.repository.dart';
import 'package:beedle/domain/services/gamification_engine.service.dart';
import 'package:beedle/foundation/exceptions/app_exceptions.dart';
import 'package:beedle/foundation/interfaces/future.usecases.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// Importe 1..N screenshots et enqueue un job d'ingestion.
final class ImportScreenshotsUseCase
    extends FutureUseCaseWithParams<IngestionJobEntity, ImportScreenshotParam> {
  ImportScreenshotsUseCase({
    required ScreenshotRepository screenshotRepository,
    required IngestionJobRepository ingestionJobRepository,
    required GamificationEngine gamificationEngine,
  }) : _screenshotRepository = screenshotRepository,
       _ingestionJobRepository = ingestionJobRepository,
       _gamificationEngine = gamificationEngine;

  final ScreenshotRepository _screenshotRepository;
  final IngestionJobRepository _ingestionJobRepository;
  final GamificationEngine _gamificationEngine;
  final Uuid _uuid = const Uuid();

  @override
  Future<IngestionJobEntity> invoke(ImportScreenshotParam params) async {
    final List<String> screenshotUuids = <String>[];

    for (final String path in params.filePaths) {
      final File file = File(path);
      if (!file.existsSync()) continue;

      final List<int> bytes = await file.readAsBytes();
      final String sha = sha256.convert(bytes).toString();

      final bool exists = await _screenshotRepository.existsBySha256(sha);
      if (exists) continue;

      final ScreenshotEntity screenshot = ScreenshotEntity(
        uuid: _uuid.v4(),
        filePath: path,
        sha256: sha,
        capturedAt: DateTime.now(),
      );
      await _screenshotRepository.upsert(screenshot);
      screenshotUuids.add(screenshot.uuid);
    }

    if (screenshotUuids.isEmpty) {
      // Use a typed exception so the UI can render a user-friendly translated
      // message instead of the raw toString() ("Exception: No new…").
      throw const AllDuplicatesException();
    }

    final IngestionJobEntity job = await _ingestionJobRepository.enqueue(
      screenshotUuids,
    );
    await _gamificationEngine.onImport();
    return job;
  }
}
