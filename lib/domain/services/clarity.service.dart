/// Contrat d'accès à Microsoft Clarity (session recording + heatmaps).
///
/// L'impl concrète vit dans la couche data — elle wrappe le SDK
/// `clarity_flutter` et respecte le consent utilisateur (pas de session
/// enregistrée tant que [setConsent(true)] n'a pas été appelé).
abstract interface class ClarityService {
  /// Project ID Clarity (dashboard → Settings).
  String get projectId;

  /// Aligne le consent avec celui d'Analytics — coupe la collecte Clarity
  /// côté SDK quand [consent] = false.
  Future<void> setConsent(bool consent);
}
