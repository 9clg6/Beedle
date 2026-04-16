import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/data/datasources/local/ingestion_job.local.data_source.dart';
import 'package:beedle/data/model/local/ingestion_job.local.model.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';
import 'package:beedle/objectbox.g.dart';

final class IngestionJobLocalDataSourceImpl
    implements IngestionJobLocalDataSource {
  IngestionJobLocalDataSourceImpl({required ObjectBoxStore store})
    : _store = store;

  final ObjectBoxStore _store;

  Box<IngestionJobLocalModel> get _box =>
      _store.store.box<IngestionJobLocalModel>();

  @override
  Future<IngestionJobLocalModel> upsert(IngestionJobLocalModel job) async {
    final IngestionJobLocalModel? existing = await getByUuid(job.uuid);
    if (existing != null) job.id = existing.id;
    job.id = _box.put(job);
    return job;
  }

  @override
  Future<IngestionJobLocalModel?> getByUuid(String uuid) async {
    final Query<IngestionJobLocalModel> q = _box
        .query(IngestionJobLocalModel_.uuid.equals(uuid))
        .build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  @override
  Future<IngestionJobLocalModel?> nextQueued() async {
    final Query<IngestionJobLocalModel> q = _box
        .query(
          IngestionJobLocalModel_.status.equals(IngestionStatus.queued.name),
        )
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
    final Query<IngestionJobLocalModel> q = _box
        .query(
          IngestionJobLocalModel_.status
              .equals(IngestionStatus.queued.name)
              .or(
                IngestionJobLocalModel_.status.equals(
                  IngestionStatus.processing.name,
                ),
              ),
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
          IngestionJobLocalModel_.status
              .equals(IngestionStatus.queued.name)
              .or(
                IngestionJobLocalModel_.status.equals(
                  IngestionStatus.processing.name,
                ),
              ),
        )
        .order(IngestionJobLocalModel_.createdAt)
        .watch(triggerImmediately: true)
        .map((Query<IngestionJobLocalModel> q) => q.find());
  }

  @override
  Stream<List<IngestionJobLocalModel>> watchActiveAndFailed() {
    return _box
        .query(
          IngestionJobLocalModel_.status
              .equals(IngestionStatus.queued.name)
              .or(
                IngestionJobLocalModel_.status.equals(
                  IngestionStatus.processing.name,
                ),
              )
              .or(
                IngestionJobLocalModel_.status.equals(
                  IngestionStatus.failed.name,
                ),
              ),
        )
        .order(IngestionJobLocalModel_.createdAt)
        .watch(triggerImmediately: true)
        .map((Query<IngestionJobLocalModel> q) => q.find());
  }

  @override
  Future<List<IngestionJobLocalModel>> failedJobs() async {
    final Query<IngestionJobLocalModel> q = _box
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
  Future<List<IngestionJobLocalModel>> activeJobs() async {
    final Query<IngestionJobLocalModel> q = _box
        .query(
          IngestionJobLocalModel_.status
              .equals(IngestionStatus.queued.name)
              .or(
                IngestionJobLocalModel_.status.equals(
                  IngestionStatus.processing.name,
                ),
              ),
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
  Future<int> removeByUuids(List<String> uuids) async {
    if (uuids.isEmpty) return 0;
    final Query<IngestionJobLocalModel> q = _box
        .query(IngestionJobLocalModel_.uuid.oneOf(uuids))
        .build();
    try {
      return q.remove();
    } finally {
      q.close();
    }
  }

  @override
  Future<void> wipe() async {
    _box.removeAll();
  }
}
