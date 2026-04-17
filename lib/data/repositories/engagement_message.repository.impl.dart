import 'package:beedle/data/datasources/local/engagement_message.local.data_source.dart';
import 'package:beedle/data/mappers/engagement_message.mapper.dart';
import 'package:beedle/data/model/local/engagement_message.local.model.dart';
import 'package:beedle/domain/entities/engagement_message.entity.dart';
import 'package:beedle/domain/repositories/engagement_message.repository.dart';

final class EngagementMessageRepositoryImpl
    implements EngagementMessageRepository {
  EngagementMessageRepositoryImpl({
    required EngagementMessageLocalDataSource dataSource,
  }) : _dataSource = dataSource;

  final EngagementMessageLocalDataSource _dataSource;

  @override
  Future<void> saveAll(List<EngagementMessageEntity> messages) async {
    await _dataSource.upsertAll(
      messages
          .map((EngagementMessageEntity e) => e.toLocalModel())
          .toList(growable: false),
    );
  }

  @override
  Future<List<EngagementMessageEntity>> byCardUuid(String cardUuid) async {
    final List<EngagementMessageLocalModel> list = await _dataSource.byCardUuid(
      cardUuid,
    );
    return list.map((EngagementMessageLocalModel m) => m.toEntity()).toList();
  }

  @override
  Future<List<EngagementMessageEntity>> pendingPool({int? limit}) async {
    final List<EngagementMessageLocalModel> list = await _dataSource
        .pendingPool(limit: limit);
    return list.map((EngagementMessageLocalModel m) => m.toEntity()).toList();
  }

  @override
  Future<void> markShown(String uuid, {DateTime? at}) =>
      _dataSource.markShown(uuid, at ?? DateTime.now());

  @override
  Future<void> markScheduled(String uuid, DateTime at) =>
      _dataSource.markScheduled(uuid, at);

  @override
  Future<void> clearScheduled(String uuid) => _dataSource.clearScheduled(uuid);

  @override
  Future<void> deleteByCardUuid(String cardUuid) =>
      _dataSource.deleteByCardUuid(cardUuid);
}
