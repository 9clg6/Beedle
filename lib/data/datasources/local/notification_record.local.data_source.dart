import 'package:beedle/data/model/local/notification_record.local.model.dart';

abstract interface class NotificationRecordLocalDataSource {
  Future<NotificationRecordLocalModel> upsert(NotificationRecordLocalModel record);
  Future<NotificationRecordLocalModel?> getByUuid(String uuid);
  Future<List<NotificationRecordLocalModel>> byTypeWithin(String type, Duration within);
  Future<void> purgeOlderThan(Duration age);
  Future<void> wipe();
}
