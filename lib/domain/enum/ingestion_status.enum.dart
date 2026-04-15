/// Statut d'un job d'ingestion (capture → OCR → LLM → embedding → persist).
enum IngestionStatus {
  queued,
  processing,
  completed,
  failed;

  static IngestionStatus fromString(String value) {
    return IngestionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => IngestionStatus.queued,
    );
  }
}
