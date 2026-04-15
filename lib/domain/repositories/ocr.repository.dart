import 'package:freezed_annotation/freezed_annotation.dart';

part 'ocr.repository.freezed.dart';

/// Résultat brut d'un OCR.
@freezed
abstract class OCRResult with _$OCRResult {
  const factory OCRResult({
    required String text,
    required double confidence,
    String? detectedLanguage,
  }) = _OCRResult;
}

abstract interface class OCRRepository {
  /// Extrait le texte depuis un fichier image local.
  Future<OCRResult> extract(String filePath);
}
