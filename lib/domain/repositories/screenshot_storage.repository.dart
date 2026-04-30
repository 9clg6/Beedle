abstract interface class ScreenshotStorageRepository {
  Future<String> uploadScreenshot(String filePath, String screenshotUuid);
}
