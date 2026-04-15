import 'package:beedle/domain/entities/digestion_result.entity.dart';
import 'package:beedle/domain/params/generate_card.param.dart';
import 'package:beedle/foundation/exceptions/app_exceptions.dart' show LLMException;

abstract interface class LLMRepository {
  /// Génère une fiche structurée depuis du texte OCR.
  ///
  /// Lance une [LLMException] en cas d'échec (timeout, rate limit, parse error).
  Future<DigestionResultEntity> digest(GenerateCardParam param);
}
