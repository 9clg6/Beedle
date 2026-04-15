import 'package:beedle/domain/enum/ingestion_status.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ingestion_job.entity.freezed.dart';

/// Entité job d'ingestion — un travail à exécuter dans la queue (OCR → LLM).
@freezed
abstract class IngestionJobEntity with _$IngestionJobEntity {
  const factory IngestionJobEntity({
    required String uuid,
    required List<String> screenshotUuids,
    required IngestionStatus status,
    required DateTime createdAt,
    @Default(0) int attempts,
    String? lastError,
    String? cardUuid,
    DateTime? completedAt,
  }) = _IngestionJobEntity;
}
