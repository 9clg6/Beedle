import 'package:beedle/data/model/local/screenshot.local.model.dart';

abstract interface class ScreenshotLocalDataSource {
  Future<ScreenshotLocalModel?> getByUuid(String uuid);
  Future<ScreenshotLocalModel?> getBySha256(String sha256);
  Future<ScreenshotLocalModel> upsert(ScreenshotLocalModel screenshot);
  Future<List<ScreenshotLocalModel>> getByCardUuid(String cardUuid);
  Future<List<ScreenshotLocalModel>> getRecent(Duration within);
  Future<void> linkToCard(String screenshotUuid, String cardUuid);
  Future<void> delete(String uuid);
  Future<void> wipe();
}
