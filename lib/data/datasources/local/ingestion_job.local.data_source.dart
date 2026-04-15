import 'package:beedle/data/model/local/ingestion_job.local.model.dart';

abstract interface class IngestionJobLocalDataSource {
  Future<IngestionJobLocalModel> upsert(IngestionJobLocalModel job);
  Future<IngestionJobLocalModel?> getByUuid(String uuid);
  Future<IngestionJobLocalModel?> nextQueued();
  Future<List<IngestionJobLocalModel>> pending();
  Stream<List<IngestionJobLocalModel>> watchPending();
  Future<List<IngestionJobLocalModel>> failedJobs();
  Future<void> wipe();
}
