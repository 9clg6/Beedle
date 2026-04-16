import 'dart:convert';

import 'package:beedle/data/datasources/local/ingestion_job.local.data_source.dart';
import 'package:beedle/data/mappers/ingestion_job.mapper.dart';
import 'package:beedle/data/model/local/ingestion_job.local.model.dart';
import 'package:beedle/domain/entities/ingestion_job.entity.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';
import 'package:beedle/domain/repositories/ingestion_job.repository.dart';
import 'package:uuid/uuid.dart';

final class IngestionJobRepositoryImpl implements IngestionJobRepository {
  IngestionJobRepositoryImpl({
    required IngestionJobLocalDataSource dataSource,
  }) : _dataSource = dataSource;

  final IngestionJobLocalDataSource _dataSource;
  final Uuid _uuid = const Uuid();

  @override
  Future<IngestionJobEntity> enqueue(List<String> screenshotUuids) async {
    final IngestionJobLocalModel local = IngestionJobLocalModel(
      uuid: _uuid.v4(),
      screenshotUuidsJson: jsonEncode(screenshotUuids),
      status: IngestionStatus.queued.name,
      createdAt: DateTime.now(),
    );
    final IngestionJobLocalModel saved = await _dataSource.upsert(local);
    return saved.toEntity();
  }

  @override
  Future<IngestionJobEntity?> nextPending() async {
    final IngestionJobLocalModel? local = await _dataSource.nextQueued();
    return local?.toEntity();
  }

  @override
  Future<IngestionJobEntity?> getByUuid(String uuid) async {
    final IngestionJobLocalModel? local = await _dataSource.getByUuid(uuid);
    return local?.toEntity();
  }

  @override
  Future<void> updateStatus(
    String uuid,
    IngestionStatus status, {
    String? error,
    String? cardUuid,
  }) async {
    final IngestionJobLocalModel? current = await _dataSource.getByUuid(uuid);
    if (current == null) return;
    current
      ..status = status.name
      ..lastError = error ?? current.lastError
      ..cardUuid = cardUuid ?? current.cardUuid
      ..attempts =
          current.attempts + (status == IngestionStatus.processing ? 1 : 0)
      ..completedAt = status == IngestionStatus.completed
          ? DateTime.now()
          : current.completedAt;
    await _dataSource.upsert(current);
  }

  @override
  Future<List<IngestionJobEntity>> pendingJobs() async {
    final List<IngestionJobLocalModel> list = await _dataSource.pending();
    return list.map((IngestionJobLocalModel e) => e.toEntity()).toList();
  }

  @override
  Stream<List<IngestionJobEntity>> watchPending() {
    return _dataSource.watchPending().map(
      (List<IngestionJobLocalModel> list) =>
          list.map((IngestionJobLocalModel e) => e.toEntity()).toList(),
    );
  }

  @override
  Stream<List<IngestionJobEntity>> watchActiveAndFailed() {
    return _dataSource.watchActiveAndFailed().map(
      (List<IngestionJobLocalModel> list) =>
          list.map((IngestionJobLocalModel e) => e.toEntity()).toList(),
    );
  }

  @override
  Future<int> retryFailed() async {
    final List<IngestionJobLocalModel> failed = await _dataSource.failedJobs();
    for (final IngestionJobLocalModel job in failed) {
      job
        ..status = IngestionStatus.queued.name
        ..lastError = null;
      await _dataSource.upsert(job);
    }
    return failed.length;
  }

  @override
  Future<int> deleteActiveJobs() async {
    final List<IngestionJobLocalModel> active = await _dataSource.activeJobs();
    if (active.isEmpty) return 0;
    final List<String> uuids = active
        .map((IngestionJobLocalModel j) => j.uuid)
        .toList();
    return _dataSource.removeByUuids(uuids);
  }
}
