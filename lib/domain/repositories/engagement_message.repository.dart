import 'package:beedle/domain/entities/engagement_message.entity.dart';

abstract interface class EngagementMessageRepository {
  Future<void> saveAll(List<EngagementMessageEntity> messages);

  Future<List<EngagementMessageEntity>> byCardUuid(String cardUuid);

  /// Pool ordered by (delayDays asc). [limit] optional.
  Future<List<EngagementMessageEntity>> pendingPool({int? limit});

  Future<void> markShown(String uuid, {DateTime? at});
  Future<void> markScheduled(String uuid, DateTime at);
  Future<void> clearScheduled(String uuid);
  Future<void> deleteByCardUuid(String cardUuid);
}
