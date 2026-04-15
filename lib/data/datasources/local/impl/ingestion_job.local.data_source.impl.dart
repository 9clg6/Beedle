import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/data/datasources/local/ingestion_job.local.data_source.dart';
import 'package:beedle/data/model/local/ingestion_job.local.model.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';
import 'package:beedle/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

final class IngestionJobLocalDataSourceImpl implements IngestionJobLocalDataSource {
  IngestionJobLocalDataSourceImpl({required ObjectBoxStore store}) : _store = store;

  final ObjectBoxStore _store;

  Box<IngestionJobLocalModel> get _box => _store.store.box<IngestionJobLocalModel>();

  @override
  Future<IngestionJobLocalModel> upsert(IngestionJobLocalModel job) async {
    final existing = await getByUuid(job.uuid);
    if (existing != null) job.id = existing.id;
    job.id = _box.put(job);
    return job;
  }

  @override
  Future<IngestionJobLocalModel?> getByUuid(String uuid) async {
    final q =
        _box.query(IngestionJobLocalModel_.uuid.equals(uuid)).build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  @override
  Future<IngestionJobLocalModel?> nextQueued() async {
    final q = _box
        .query(IngestionJobLocalModel_.status.equals(IngestionStatus.queued.name))
        .order(IngestionJobLocalModel_.createdAt)
        .build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  @override
  Future<List<IngestionJobLocalModel>> pending() async {
    final q = _box
        .query(
          IngestionJobLocalModel_.status.equals(IngestionStatus.queued.name)
            .or(IngestionJobLocalModel_.status.equals(IngestionStatus.processing.name)),
        )
        .order(IngestionJobLocalModel_.createdAt)
        .build();
    try {
      return q.find();
    } finally {
      q.close();
    }
  }

  @override
  Stream<List<IngestionJobLocalModel>> watchPending() {
    return _box
        .query(
          IngestionJobLocalModel_.status.equals(IngestionStatus.queued.name)
            .or(IngestionJobLocalModel_.status.equals(IngestionStatus.processing.name)),
        )
        .order(IngestionJobLocalModel_.createdAt)
        .watch(triggerImmediately: true)
        .map((q) => q.find());
  }

  @override
  Future<List<IngestionJobLocalModel>> failedJobs() async {
    final q = _box
        .query(
          IngestionJobLocalModel_.status.equals(IngestionStatus.failed.name),
        )
        .order(IngestionJobLocalModel_.createdAt)
        .build();
    try {
      return q.find();
    } finally {
      q.close();
    }
  }

  @override
  Future<void> wipe() async {
    _box.removeAll();
  }
}
