import 'package:beedle/data/model/local/screenshot.local.model.dart';
import 'package:beedle/domain/entities/screenshot.entity.dart';

extension ScreenshotLocalModelX on ScreenshotLocalModel {
  ScreenshotEntity toEntity() => ScreenshotEntity(
        uuid: uuid,
        filePath: filePath,
        sha256: sha256,
        capturedAt: capturedAt,
        ocrText: ocrText,
        ocrConfidence: ocrConfidence,
        cardUuid: cardUuid,
        detectedLanguage: detectedLanguage,
      );
}

extension ScreenshotEntityToLocalX on ScreenshotEntity {
  ScreenshotLocalModel toLocalModel({int? id}) => ScreenshotLocalModel(
        id: id ?? 0,
        uuid: uuid,
        filePath: filePath,
        sha256: sha256,
        capturedAt: capturedAt,
        ocrText: ocrText,
        ocrConfidence: ocrConfidence,
        cardUuid: cardUuid,
        detectedLanguage: detectedLanguage,
      );
}
