import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/data/datasources/local/notification_record.local.data_source.dart';
import 'package:beedle/data/model/local/notification_record.local.model.dart';
import 'package:beedle/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

final class NotificationRecordLocalDataSourceImpl
    implements NotificationRecordLocalDataSource {
  NotificationRecordLocalDataSourceImpl({required ObjectBoxStore store}) : _store = store;

  final ObjectBoxStore _store;

  Box<NotificationRecordLocalModel> get _box =>
      _store.store.box<NotificationRecordLocalModel>();

  @override
  Future<NotificationRecordLocalModel> upsert(NotificationRecordLocalModel record) async {
    final existing = await getByUuid(record.uuid);
    if (existing != null) record.id = existing.id;
    record.id = _box.put(record);
    return record;
  }

  @override
  Future<NotificationRecordLocalModel?> getByUuid(String uuid) async {
    final q =
        _box.query(NotificationRecordLocalModel_.uuid.equals(uuid)).build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  @override
  Future<List<NotificationRecordLocalModel>> byTypeWithin(String type, Duration within) async {
    final threshold = DateTime.now().subtract(within);
    final q = _box
        .query(
          NotificationRecordLocalModel_.type.equals(type).and(
                NotificationRecordLocalModel_.scheduledAt.greaterThan(
                  threshold.millisecondsSinceEpoch,
                ),
              ),
        )
        .build();
    try {
      return q.find();
    } finally {
      q.close();
    }
  }

  @override
  Future<void> purgeOlderThan(Duration age) async {
    final threshold = DateTime.now().subtract(age);
    final q = _box
        .query(
          NotificationRecordLocalModel_.scheduledAt.lessThan(
            threshold.millisecondsSinceEpoch,
          ),
        )
        .build();
    try {
      final old = q.find();
      _box.removeMany(old.map((e) => e.id).toList());
    } finally {
      q.close();
    }
  }

  @override
  Future<void> wipe() async {
    _box.removeAll();
  }
}
