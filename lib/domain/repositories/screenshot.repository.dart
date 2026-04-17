import 'package:beedle/domain/entities/screenshot.entity.dart';

abstract interface class ScreenshotRepository {
  Future<ScreenshotEntity> upsert(ScreenshotEntity screenshot);

  Future<ScreenshotEntity?> getByUuid(String uuid);

  Future<List<ScreenshotEntity>> getByCardUuid(String cardUuid);

  Future<bool> existsBySha256(String sha256);

  Future<List<ScreenshotEntity>> getRecent({
    Duration within = const Duration(minutes: 5),
  });

  Future<void> linkToCard(String screenshotUuid, String cardUuid);

  Future<void> delete(String uuid);
}
