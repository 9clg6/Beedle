import 'package:beedle/data/model/local/engagement_message.local.model.dart';

abstract interface class EngagementMessageLocalDataSource {
  Future<EngagementMessageLocalModel> upsert(EngagementMessageLocalModel m);
  Future<List<EngagementMessageLocalModel>> upsertAll(
    List<EngagementMessageLocalModel> list,
  );
  Future<EngagementMessageLocalModel?> getByUuid(String uuid);
  Future<List<EngagementMessageLocalModel>> byCardUuid(String cardUuid);

  /// Messages non-montrés, ordonnés par (delayDays asc, createdAt desc).
  /// Limite optionnelle.
  Future<List<EngagementMessageLocalModel>> pendingPool({int? limit});

  Future<void> markShown(String uuid, DateTime at);
  Future<void> markScheduled(String uuid, DateTime at);
  Future<void> clearScheduled(String uuid);
  Future<void> deleteByCardUuid(String cardUuid);
}
