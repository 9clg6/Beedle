import 'dart:convert';

import 'package:beedle/data/model/local/card.local.model.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/enum/card_intent.enum.dart';
import 'package:beedle/domain/enum/card_level.enum.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';

extension CardLocalModelX on CardLocalModel {
  CardEntity toEntity() => CardEntity(
    uuid: uuid,
    title: title,
    summary: summary,
    fullContent: fullContent,
    level: CardLevel.fromString(level),
    tags: _decodeStringList(tagsJson),
    language: language,
    teaserHook: teaserHook,
    status: IngestionStatus.fromString(status),
    createdAt: createdAt,
    viewedCount: viewedCount,
    viewedAt: viewedAt,
    testedAt: testedAt,
    estimatedMinutes: estimatedMinutes,
    sourceUrl: sourceUrl,
    embedding: embedding ?? <double>[],
    intent: CardIntent.fromString(intent),
    intentOverridden: intentOverridden,
    primaryAction: primaryAction,
  );
}

extension CardEntityToLocalX on CardEntity {
  CardLocalModel toLocalModel({int? id}) => CardLocalModel(
    id: id ?? 0,
    uuid: uuid,
    title: title,
    summary: summary,
    fullContent: fullContent,
    level: level.name,
    tagsJson: jsonEncode(tags),
    language: language,
    teaserHook: teaserHook,
    status: status.name,
    createdAt: createdAt,
    viewedCount: viewedCount,
    viewedAt: viewedAt,
    testedAt: testedAt,
    estimatedMinutes: estimatedMinutes,
    sourceUrl: sourceUrl,
    embedding: embedding.isEmpty ? null : embedding,
    intent: intent.name,
    intentOverridden: intentOverridden,
    primaryAction: primaryAction,
  );
}

List<String> _decodeStringList(String raw) {
  try {
    final dynamic decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.map((dynamic e) => e.toString()).toList();
    }
  } on Exception {
    // ignore
  }
  return <String>[];
}
