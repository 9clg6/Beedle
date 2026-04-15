import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generate_card.param.freezed.dart';

/// Paramètres pour la génération LLM d'une fiche depuis du texte OCR.
@Freezed(copyWith: true)
abstract class GenerateCardParam with _$GenerateCardParam {
  const factory GenerateCardParam({
    required String ocrText,
    required List<ContentCategory> userCategories,
    @Default('auto') String preferredLanguage,
  }) = _GenerateCardParam;
}
