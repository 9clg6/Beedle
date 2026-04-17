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
}
