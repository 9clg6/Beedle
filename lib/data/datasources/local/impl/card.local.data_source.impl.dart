import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/data/datasources/local/card.local.data_source.dart';
import 'package:beedle/data/model/local/card.local.model.dart';
import 'package:beedle/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

final class CardLocalDataSourceImpl implements CardLocalDataSource {
  CardLocalDataSourceImpl({required ObjectBoxStore store}) : _store = store;

  final ObjectBoxStore _store;

  Box<CardLocalModel> get _box => _store.store.box<CardLocalModel>();

  @override
  Future<List<CardLocalModel>> getAll({int? limit, int? offset}) async {
    final query = _box
        .query()
        .order(CardLocalModel_.createdAt, flags: Order.descending)
        .build();
    try {
      if (offset != null) query.offset = offset;
      if (limit != null) query.limit = limit;
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<CardLocalModel?> getByUuid(String uuid) async {
    final query =
        _box.query(CardLocalModel_.uuid.equals(uuid)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  @override
  Future<CardLocalModel> upsert(CardLocalModel card) async {
    final existing = await getByUuid(card.uuid);
    if (existing != null) card.id = existing.id;
    card.id = _box.put(card);
    return card;
  }

  @override
  Future<void> delete(String uuid) async {
    final existing = await getByUuid(uuid);
    if (existing != null) _box.remove(existing.id);
  }

  @override
  Future<List<CardLocalModel>> nearestNeighbors({
    required List<double> queryEmbedding,
    int limit = 10,
  }) async {
    final query = _box
        .query(
          CardLocalModel_.embedding.nearestNeighborsF32(queryEmbedding, limit),
        )
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<CardLocalModel?> oldestUnviewed() async {
    final query = _box
        .query(CardLocalModel_.viewedAt.isNull())
        .order(CardLocalModel_.createdAt)
        .build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  @override
  Future<List<CardLocalModel>> staleViewed({
    int limit = 3,
    Duration staleAfter = const Duration(days: 14),
  }) async {
    final threshold = DateTime.now().subtract(staleAfter);
    final query = _box
        .query(
          CardLocalModel_.viewedAt.lessThan(threshold.millisecondsSinceEpoch),
        )
        .order(CardLocalModel_.viewedAt)
        .build();
    try {
      query.limit = limit;
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<void> markViewed(String uuid) async {
    final c = await getByUuid(uuid);
    if (c == null) return;
    c
      ..viewedAt = DateTime.now()
      ..viewedCount = c.viewedCount + 1;
    _box.put(c);
  }

  @override
  Future<void> markTested(String uuid) async {
    final c = await getByUuid(uuid);
    if (c == null) return;
    c.testedAt = DateTime.now();
    _box.put(c);
  }

  @override
  Future<int> count() async => _box.count();

  @override
  Stream<List<CardLocalModel>> watchAll() {
    return _box
        .query()
        .order(CardLocalModel_.createdAt, flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((q) => q.find());
  }

  @override
  Future<void> wipe() async {
    _box.removeAll();
  }
}
