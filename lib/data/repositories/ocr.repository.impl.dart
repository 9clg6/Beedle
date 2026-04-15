import 'package:beedle/domain/repositories/ocr.repository.dart';
import 'package:beedle/foundation/exceptions/app_exceptions.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Implémentation OCR via Google ML Kit on-device.
///
/// Support multilingue : on utilise le script `TextRecognitionScript.latin`
/// qui couvre français, anglais, espagnol, etc.
final class OCRRepositoryImpl implements OCRRepository {
  OCRRepositoryImpl()
      : _recognizer = TextRecognizer();

  final TextRecognizer _recognizer;
  final Log _log = Log.named('OCRRepository');

  @override
  Future<OCRResult> extract(String filePath) async {
    try {
      final input = InputImage.fromFilePath(filePath);
      final result = await _recognizer.processImage(input);

      final fullText = result.text;
      final confidence = _computeConfidence(result);

      if (fullText.trim().length < 10) {
        _log.warn('OCR returned < 10 chars for $filePath');
      }

      return OCRResult(
        text: fullText,
        confidence: confidence,
      );
    } on Exception catch (e, st) {
      _log.error('OCR failed for $filePath: $e', e, st);
      throw OCRFailureException('OCR failed', cause: e);
    }
  }

  double _computeConfidence(RecognizedText text) {
    if (text.blocks.isEmpty) return 0;
    final totalChars = text.text.length;
    if (totalChars == 0) return 0;
    // Heuristique simple : on part du principe que plus il y a de texte extrait,
    // plus la confiance est haute. MLKit ne retourne pas de score par défaut.
    return (totalChars / (totalChars + 50)).clamp(0.1, 0.99);
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }
}
