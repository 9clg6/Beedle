import 'package:beedle/data/datasources/local/notification_record.local.data_source.dart';
import 'package:beedle/data/mappers/notification_record.mapper.dart';
import 'package:beedle/data/model/local/notification_record.local.model.dart';
import 'package:beedle/domain/entities/notification_record.entity.dart';
import 'package:beedle/domain/enum/notification_type.enum.dart';
import 'package:beedle/domain/repositories/notification.repository.dart';

final class NotificationRecordRepositoryImpl implements NotificationRecordRepository {
  NotificationRecordRepositoryImpl({
    required NotificationRecordLocalDataSource dataSource,
  }) : _dataSource = dataSource;

  final NotificationRecordLocalDataSource _dataSource;

  @override
  Future<NotificationRecordEntity> persist(NotificationRecordEntity record) async {
    final saved = await _dataSource.upsert(record.toLocalModel());
    return saved.toEntity();
  }

  @override
  Future<List<NotificationRecordEntity>> byType(
    NotificationType type, {
    Duration within = const Duration(days: 1),
  }) async {
    final list =
        await _dataSource.byTypeWithin(type.name, within);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> markSent(String uuid) => _updateTimestamp(uuid, (m) => m..sentAt = DateTime.now());

  @override
  Future<void> markTapped(String uuid) => _updateTimestamp(uuid, (m) => m..tappedAt = DateTime.now());

  @override
  Future<void> markDismissed(String uuid) => _updateTimestamp(uuid, (m) => m..dismissedAt = DateTime.now());

  @override
  Future<void> purgeOlderThan(Duration age) => _dataSource.purgeOlderThan(age);

  Future<void> _updateTimestamp(
    String uuid,
    NotificationRecordLocalModel Function(NotificationRecordLocalModel) mutator,
  ) async {
    final existing = await _dataSource.getByUuid(uuid);
    if (existing == null) return;
    await _dataSource.upsert(mutator(existing));
  }
}
