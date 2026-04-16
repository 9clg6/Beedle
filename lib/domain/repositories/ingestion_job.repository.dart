import 'package:beedle/domain/entities/ingestion_job.entity.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';

abstract interface class IngestionJobRepository {
  Future<IngestionJobEntity> enqueue(List<String> screenshotUuids);

  Future<IngestionJobEntity?> nextPending();

  /// Retourne le job correspondant au uuid, ou `null` s'il n'existe plus
  /// (supprimé par l'utilisateur via cancel, ou purgé).
  Future<IngestionJobEntity?> getByUuid(String uuid);

  Future<void> updateStatus(
    String uuid,
    IngestionStatus status, {
    String? error,
    String? cardUuid,
  });

  Future<List<IngestionJobEntity>> pendingJobs();

  Stream<List<IngestionJobEntity>> watchPending();

  /// Stream des jobs actifs (queued|processing) + failed.
  /// Utilisé par l'UI pour afficher une card de progression persistante
  /// qui couvre à la fois la digestion en cours et les échecs visibles.
  Stream<List<IngestionJobEntity>> watchActiveAndFailed();

  /// Remet en queue tous les jobs en status `failed`.
  /// Retourne le nombre de jobs réinjectés.
  Future<int> retryFailed();

  /// Annule tous les jobs actifs (queued|processing) en les supprimant
  /// de la base. Le pipeline qui serait en cours de traitement détectera
  /// que le job n'existe plus et abortera sans persister de card.
  /// Retourne le nombre de jobs annulés.
  Future<int> deleteActiveJobs();
}
