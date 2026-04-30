import 'package:freezed_annotation/freezed_annotation.dart';

part 'screenshot.entity.freezed.dart';

/// Entité screenshot — représente une image capturée par l'utilisateur.
///
/// Stockée localement dans le sandbox de l'app. Liée à 0 ou 1 Card (via cardUuid).
@freezed
abstract class ScreenshotEntity with _$ScreenshotEntity {
  const factory ScreenshotEntity({
    required String uuid,
    required String filePath,
    required String sha256,
    required DateTime capturedAt,
    @Default('') String ocrText,
    @Default(0.0) double ocrConfidence,
    String? cardUuid,
    String? detectedLanguage,
    String? remoteUrl,
  }) = _ScreenshotEntity;
}
