import 'package:beedle/domain/enum/card_intent.enum.dart';
import 'package:beedle/domain/enum/card_level.enum.dart';
import 'package:beedle/domain/enum/engagement_message.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'digestion_result.entity.freezed.dart';

/// Sortie structurée du LLM après digestion.
///
/// Le LLM agit comme un **nettoyeur + formateur**, pas comme un résumeur :
/// [fullContent] est le verbatim nettoyé (markdown), [summary] est juste
/// un TL;DR court affiché en header. [teaserHook] est calculé depuis le
/// fullContent pour alimenter les push-teasers.
///
/// [engagementMessages] = pool de 3-6 micro-messages pré-générés pour la
/// couche d'engagement (Terminal Card + push notifications).
/// Voir `docs/tech-spec-engagement-layer-2026-04-15.md`.
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
    @Default(<DigestedEngagementMessage>[])
    List<DigestedEngagementMessage> engagementMessages,
    @Default(CardIntent.read) CardIntent intent,
    int? estimatedMinutes,
    String? sourceUrl,
    String? primaryAction,
  }) = _DigestionResultEntity;
}

/// Message d'engagement tel que renvoyé par le LLM (sans cardUuid/createdAt,
/// qui sont injectés côté pipeline à la persistance).
@freezed
abstract class DigestedEngagementMessage with _$DigestedEngagementMessage {
  const factory DigestedEngagementMessage({
    required String content,
    required EngagementMessageType type,
    required EngagementMessageFormat format,
    required int delayDays,
  }) = _DigestedEngagementMessage;
}
