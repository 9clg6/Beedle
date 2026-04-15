import 'package:beedle/data/model/local/card.local.model.dart';

abstract interface class CardLocalDataSource {
  Future<List<CardLocalModel>> getAll({int? limit, int? offset});
  Future<CardLocalModel?> getByUuid(String uuid);
  Future<CardLocalModel> upsert(CardLocalModel card);
  Future<void> delete(String uuid);
  Future<List<CardLocalModel>> nearestNeighbors({
    required List<double> queryEmbedding,
    int limit = 10,
  });
  Future<CardLocalModel?> oldestUnviewed();
  Future<List<CardLocalModel>> staleViewed({int limit = 3, Duration staleAfter = const Duration(days: 14)});
  Future<void> markViewed(String uuid);
  Future<void> markTested(String uuid);
  Future<int> count();
  Stream<List<CardLocalModel>> watchAll();
  Future<void> wipe();
}
