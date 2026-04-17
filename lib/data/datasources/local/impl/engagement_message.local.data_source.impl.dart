import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/data/datasources/local/engagement_message.local.data_source.dart';
import 'package:beedle/data/model/local/engagement_message.local.model.dart';
import 'package:beedle/objectbox.g.dart';

final class EngagementMessageLocalDataSourceImpl
    implements EngagementMessageLocalDataSource {
  EngagementMessageLocalDataSourceImpl({required ObjectBoxStore store})
    : _store = store;

  final ObjectBoxStore _store;

  Box<EngagementMessageLocalModel> get _box =>
      _store.store.box<EngagementMessageLocalModel>();

  @override
  Future<EngagementMessageLocalModel> upsert(
    EngagementMessageLocalModel m,
  ) async {
    final EngagementMessageLocalModel? existing = await getByUuid(m.uuid);
    if (existing != null) m.id = existing.id;
    m.id = _box.put(m);
    return m;
  }

  @override
  Future<List<EngagementMessageLocalModel>> upsertAll(
    List<EngagementMessageLocalModel> list,
  ) async {
    final List<EngagementMessageLocalModel> out =
        <EngagementMessageLocalModel>[];
    for (final EngagementMessageLocalModel m in list) {
      out.add(await upsert(m));
    }
    return out;
  }

  @override
  Future<EngagementMessageLocalModel?> getByUuid(String uuid) async {
    final Query<EngagementMessageLocalModel> q = _box
        .query(EngagementMessageLocalModel_.uuid.equals(uuid))
        .build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  @override
  Future<List<EngagementMessageLocalModel>> byCardUuid(String cardUuid) async {
    final Query<EngagementMessageLocalModel> q = _box
        .query(EngagementMessageLocalModel_.cardUuid.equals(cardUuid))
        .order(EngagementMessageLocalModel_.delayDays)
        .build();
    try {
      return q.find();
    } finally {
      q.close();
    }
  }

  @override
  Future<List<EngagementMessageLocalModel>> pendingPool({int? limit}) async {
    final Query<EngagementMessageLocalModel> q = _box
        .query(EngagementMessageLocalModel_.shownAt.isNull())
        .order(EngagementMessageLocalModel_.delayDays)
        .build();
    try {
      if (limit != null) q.limit = limit;
      return q.find();
    } finally {
      q.close();
    }
  }

  @override
  Future<void> markShown(String uuid, DateTime at) async {
    final EngagementMessageLocalModel? m = await getByUuid(uuid);
    if (m == null) return;
    m.shownAt = at;
    await upsert(m);
  }

  @override
  Future<void> markScheduled(String uuid, DateTime at) async {
    final EngagementMessageLocalModel? m = await getByUuid(uuid);
    if (m == null) return;
    m.scheduledAt = at;
    await upsert(m);
  }

  @override
  Future<void> clearScheduled(String uuid) async {
    final EngagementMessageLocalModel? m = await getByUuid(uuid);
    if (m == null) return;
    m.scheduledAt = null;
    await upsert(m);
  }

  @override
  Future<void> deleteByCardUuid(String cardUuid) async {
    final List<EngagementMessageLocalModel> list = await byCardUuid(cardUuid);
    _box.removeMany(list.map((EngagementMessageLocalModel m) => m.id).toList());
  }
}
