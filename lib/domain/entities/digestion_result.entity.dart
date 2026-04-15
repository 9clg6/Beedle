import 'package:beedle/domain/enum/card_level.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'digestion_result.entity.freezed.dart';

/// Sortie structurée du LLM après digestion.
///
/// Le LLM agit comme un **nettoyeur + formateur**, pas comme un résumeur :
/// [fullContent] est le verbatim nettoyé (markdown), [summary] est juste
/// un TL;DR court affiché en header. [teaserHook] est calculé depuis le
/// fullContent pour alimenter les push-teasers.
@freezed
abstract class DigestionResultEntity with _$DigestionResultEntity {
  const factory DigestionResultEntity({
    required String title,
    required String summary,
    required String fullContent,
    required List<String> tags,
    required CardLevel level,
    required String language,
    required String teaserHook,
    int? estimatedMinutes,
    String? sourceUrl,
  }) = _DigestionResultEntity;
}
