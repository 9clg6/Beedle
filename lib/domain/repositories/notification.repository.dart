import 'package:beedle/domain/entities/notification_record.entity.dart';
import 'package:beedle/domain/enum/notification_type.enum.dart';

abstract interface class NotificationRecordRepository {
  Future<NotificationRecordEntity> persist(NotificationRecordEntity record);

  Future<List<NotificationRecordEntity>> byType(
    NotificationType type, {
    Duration within = const Duration(days: 1),
  });

  Future<void> markSent(String uuid);

  Future<void> markTapped(String uuid);

  Future<void> markDismissed(String uuid);

  Future<void> purgeOlderThan(Duration age);
}
