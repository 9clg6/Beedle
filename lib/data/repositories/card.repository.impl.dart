import 'package:beedle/data/datasources/local/card.local.data_source.dart';
import 'package:beedle/data/datasources/local/subscription_snapshot.local.data_source.dart';
import 'package:beedle/data/mappers/card.mapper.dart';
import 'package:beedle/data/mappers/subscription_snapshot.mapper.dart';
import 'package:beedle/data/model/local/card.local.model.dart';
import 'package:beedle/data/model/local/subscription_snapshot.local.model.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/repositories/card.repository.dart';

final class CardRepositoryImpl implements CardRepository {
  CardRepositoryImpl({
    required CardLocalDataSource cardLocalDataSource,
    required SubscriptionSnapshotLocalDataSource subscriptionSnapshotLocalDataSource,
  })  : _cardLocalDataSource = cardLocalDataSource,
        _subscriptionSnapshotLocalDataSource = subscriptionSnapshotLocalDataSource;

  final CardLocalDataSource _cardLocalDataSource;
  final SubscriptionSnapshotLocalDataSource _subscriptionSnapshotLocalDataSource;

  @override
  Future<List<CardEntity>> getAll({int? limit, int? offset}) async {
    final list = await _cardLocalDataSource.getAll(limit: limit, offset: offset);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<CardEntity?> getByUuid(String uuid) async {
    final local = await _cardLocalDataSource.getByUuid(uuid);
    return local?.toEntity();
  }

  @override
  Future<CardEntity> upsert(CardEntity card) async {
    final saved = await _cardLocalDataSource.upsert(card.toLocalModel());
    return saved.toEntity();
  }

  @override
  Future<void> delete(String uuid) => _cardLocalDataSource.delete(uuid);

  @override
  Future<List<CardEntity>> semanticSearch({
    required List<double> queryEmbedding,
    int limit = 10,
    bool restrictToCurrentMonth = false,
  }) async {
    final results =
        await _cardLocalDataSource.nearestNeighbors(queryEmbedding: queryEmbedding, limit: limit);

    if (!restrictToCurrentMonth) {
      return results.map((e) => e.toEntity()).toList();
    }

    final subLocal =
        await _subscriptionSnapshotLocalDataSource.load();
    final cycleStart = subLocal.toEntity().monthlyCycleStart;
    return results
        .where((c) => !c.createdAt.isBefore(cycleStart))
        .map((e) => e.toEntity())
        .toList();
  }

  @override
  Future<CardEntity?> pickTodayCard({List<String>? preferredTags}) async {
    final oldest = await _cardLocalDataSource.oldestUnviewed();
    if (oldest != null) return oldest.toEntity();
    final stale =
        await _cardLocalDataSource.staleViewed(limit: 1);
    return stale.isNotEmpty ? stale.first.toEntity() : null;
  }

  @override
  Future<List<CardEntity>> getStaleCards({int limit = 3}) async {
    final list = await _cardLocalDataSource.staleViewed(limit: limit);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> markViewed(String uuid) => _cardLocalDataSource.markViewed(uuid);

  @override
  Future<void> markTested(String uuid) => _cardLocalDataSource.markTested(uuid);

  @override
  Stream<List<CardEntity>> watchAll() {
    return _cardLocalDataSource.watchAll().map(
          (list) =>
              list.map((e) => e.toEntity()).toList(),
        );
  }

  @override
  Future<int> count() => _cardLocalDataSource.count();
}
