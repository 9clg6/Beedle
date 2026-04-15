import 'package:beedle/domain/entities/ingestion_job.entity.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';

abstract interface class IngestionJobRepository {
  Future<IngestionJobEntity> enqueue(List<String> screenshotUuids);

  Future<IngestionJobEntity?> nextPending();

  Future<void> updateStatus(String uuid, IngestionStatus status, {String? error, String? cardUuid});

  Future<List<IngestionJobEntity>> pendingJobs();

  Stream<List<IngestionJobEntity>> watchPending();

  /// Remet en queue tous les jobs en status `failed`.
  /// Retourne le nombre de jobs réinjectés.
  Future<int> retryFailed();
}
