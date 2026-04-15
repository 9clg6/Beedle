import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/data/datasources/local/screenshot.local.data_source.dart';
import 'package:beedle/data/model/local/screenshot.local.model.dart';
import 'package:beedle/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

final class ScreenshotLocalDataSourceImpl implements ScreenshotLocalDataSource {
  ScreenshotLocalDataSourceImpl({required ObjectBoxStore store}) : _store = store;

  final ObjectBoxStore _store;

  Box<ScreenshotLocalModel> get _box => _store.store.box<ScreenshotLocalModel>();

  @override
  Future<ScreenshotLocalModel?> getByUuid(String uuid) async {
    final q =
        _box.query(ScreenshotLocalModel_.uuid.equals(uuid)).build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  @override
  Future<ScreenshotLocalModel?> getBySha256(String sha256) async {
    final q =
        _box.query(ScreenshotLocalModel_.sha256.equals(sha256)).build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  @override
  Future<ScreenshotLocalModel> upsert(ScreenshotLocalModel screenshot) async {
    final existing = await getByUuid(screenshot.uuid);
    if (existing != null) screenshot.id = existing.id;
    screenshot.id = _box.put(screenshot);
    return screenshot;
  }

  @override
  Future<List<ScreenshotLocalModel>> getByCardUuid(String cardUuid) async {
    final q =
        _box.query(ScreenshotLocalModel_.cardUuid.equals(cardUuid)).build();
    try {
      return q.find();
    } finally {
      q.close();
    }
  }

  @override
  Future<List<ScreenshotLocalModel>> getRecent(Duration within) async {
    final threshold = DateTime.now().subtract(within);
    final q = _box
        .query(
          ScreenshotLocalModel_.capturedAt.greaterThan(threshold.millisecondsSinceEpoch),
        )
        .order(ScreenshotLocalModel_.capturedAt, flags: Order.descending)
        .build();
    try {
      return q.find();
    } finally {
      q.close();
    }
  }

  @override
  Future<void> linkToCard(String screenshotUuid, String cardUuid) async {
    final s = await getByUuid(screenshotUuid);
    if (s == null) return;
    s.cardUuid = cardUuid;
    _box.put(s);
  }

  @override
  Future<void> delete(String uuid) async {
    final s = await getByUuid(uuid);
    if (s != null) _box.remove(s.id);
  }

  @override
  Future<void> wipe() async {
    _box.removeAll();
  }
}
