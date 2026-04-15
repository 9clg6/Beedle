import 'package:beedle/data/datasources/local/screenshot.local.data_source.dart';
import 'package:beedle/data/mappers/screenshot.mapper.dart';
import 'package:beedle/data/model/local/screenshot.local.model.dart';
import 'package:beedle/domain/entities/screenshot.entity.dart';
import 'package:beedle/domain/repositories/screenshot.repository.dart';

final class ScreenshotRepositoryImpl implements ScreenshotRepository {
  ScreenshotRepositoryImpl({
    required ScreenshotLocalDataSource screenshotLocalDataSource,
  }) : _ds = screenshotLocalDataSource;

  final ScreenshotLocalDataSource _ds;

  @override
  Future<ScreenshotEntity> upsert(ScreenshotEntity screenshot) async {
    final saved = await _ds.upsert(screenshot.toLocalModel());
    return saved.toEntity();
  }

  @override
  Future<ScreenshotEntity?> getByUuid(String uuid) async {
    final local = await _ds.getByUuid(uuid);
    return local?.toEntity();
  }

  @override
  Future<List<ScreenshotEntity>> getByCardUuid(String cardUuid) async {
    final list = await _ds.getByCardUuid(cardUuid);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<bool> existsBySha256(String sha256) async {
    return (await _ds.getBySha256(sha256)) != null;
  }

  @override
  Future<List<ScreenshotEntity>> getRecent({Duration within = const Duration(minutes: 5)}) async {
    final list = await _ds.getRecent(within);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> linkToCard(String screenshotUuid, String cardUuid) =>
      _ds.linkToCard(screenshotUuid, cardUuid);

  @override
  Future<void> delete(String uuid) => _ds.delete(uuid);
}
