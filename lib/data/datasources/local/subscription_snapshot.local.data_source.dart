import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/data/model/local/subscription_snapshot.local.model.dart';
import 'package:beedle/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

abstract interface class SubscriptionSnapshotLocalDataSource {
  Future<SubscriptionSnapshotLocalModel> load();
  Future<void> save(SubscriptionSnapshotLocalModel snapshot);
  Stream<SubscriptionSnapshotLocalModel> watch();
  Future<void> wipe();
}

final class SubscriptionSnapshotLocalDataSourceImpl
    implements SubscriptionSnapshotLocalDataSource {
  SubscriptionSnapshotLocalDataSourceImpl({required ObjectBoxStore store})
    : _store = store;

  final ObjectBoxStore _store;

  Box<SubscriptionSnapshotLocalModel> get _box =>
      _store.store.box<SubscriptionSnapshotLocalModel>();

  @override
  Future<SubscriptionSnapshotLocalModel> load() async {
    final SubscriptionSnapshotLocalModel? existing = _box.get(1);
    if (existing != null) return existing;
    final DateTime now = DateTime.now();
    final SubscriptionSnapshotLocalModel initial =
        SubscriptionSnapshotLocalModel(
          lastSyncedAt: now,
          monthlyCycleStart: DateTime(now.year, now.month),
        );
    _box.put(initial);
    return initial;
  }

  @override
  Future<void> save(SubscriptionSnapshotLocalModel snapshot) async {
    snapshot.id = 1;
    _box.put(snapshot);
  }

  @override
  Stream<SubscriptionSnapshotLocalModel> watch() {
    return _box.query().watch(triggerImmediately: true).map((
      Query<SubscriptionSnapshotLocalModel> query,
    ) {
      final SubscriptionSnapshotLocalModel? first = query.findFirst();
      if (first != null) return first;
      final DateTime now = DateTime.now();
      return SubscriptionSnapshotLocalModel(
        lastSyncedAt: now,
        monthlyCycleStart: DateTime(now.year, now.month),
      );
    });
  }

  @override
  Future<void> wipe() async {
    _box.removeAll();
  }
}
