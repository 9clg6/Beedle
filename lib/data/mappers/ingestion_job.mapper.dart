import 'dart:convert';

import 'package:beedle/data/model/local/ingestion_job.local.model.dart';
import 'package:beedle/domain/entities/ingestion_job.entity.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';

extension IngestionJobLocalModelX on IngestionJobLocalModel {
  IngestionJobEntity toEntity() {
    final List<String> uuids =
        (jsonDecode(screenshotUuidsJson) as List<dynamic>)
            .map((dynamic e) => e.toString())
            .toList();
    return IngestionJobEntity(
      uuid: uuid,
      screenshotUuids: uuids,
      status: IngestionStatus.fromString(status),
      createdAt: createdAt,
      attempts: attempts,
      lastError: lastError,
      cardUuid: cardUuid,
      completedAt: completedAt,
    );
  }
}

extension IngestionJobEntityToLocalX on IngestionJobEntity {
  IngestionJobLocalModel toLocalModel({int? id}) => IngestionJobLocalModel(
    id: id ?? 0,
    uuid: uuid,
    screenshotUuidsJson: jsonEncode(screenshotUuids),
    status: status.name,
    createdAt: createdAt,
    attempts: attempts,
    lastError: lastError,
    cardUuid: cardUuid,
    completedAt: completedAt,
  );
}
