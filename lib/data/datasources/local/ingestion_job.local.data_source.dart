import 'package:beedle/data/model/local/ingestion_job.local.model.dart';

abstract interface class IngestionJobLocalDataSource {
  Future<IngestionJobLocalModel> upsert(IngestionJobLocalModel job);
  Future<IngestionJobLocalModel?> getByUuid(String uuid);
  Future<IngestionJobLocalModel?> nextQueued();
  Future<List<IngestionJobLocalModel>> pending();
  Stream<List<IngestionJobLocalModel>> watchPending();
  Stream<List<IngestionJobLocalModel>> watchActiveAndFailed();
  Future<List<IngestionJobLocalModel>> failedJobs();
  Future<List<IngestionJobLocalModel>> activeJobs();
  Future<int> removeByUuids(List<String> uuids);
  Future<void> wipe();
}
