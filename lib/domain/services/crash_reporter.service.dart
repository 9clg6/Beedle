/// Contrat du service de crash reporting — impl via Firebase Crashlytics
/// dans la couche data (voir `FirebaseCrashReporterService`).
///
/// Extrait pour respecter la layer separation : le domain et la presentation
/// ne référencent JAMAIS directement `firebase_crashlytics`.
abstract interface class CrashReporterService {
  /// Associe les prochains crashes et logs à [uid] (stable user identifier).
  /// Best-effort : une erreur native (Firebase non init, offline) ne doit
  /// jamais remonter à l'appelant.
  Future<void> setUserIdentifier(String uid);

  /// Enregistre une erreur non-fatale capturée par un bloc `try/catch`.
  /// Utilisé par le pipeline d'ingestion pour tracer les échecs LLM/OCR
  /// sans faire crasher l'app. Best-effort : ne doit jamais propager.
  ///
  /// [reason] est un label court (ex: "ingestion_pipeline") qui permet de
  /// regrouper les issues côté console Crashlytics. [context] est un set
  /// de paires clé/valeur courtes qui remonteront comme custom keys.
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    Map<String, Object>? context,
  });
}
