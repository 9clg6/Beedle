import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';

/// Service métier qui arbitre les scans IA gratuits vs Pro.
///
/// Règle v1 :
///   • Free : [ScanQuotaService.freeMonthlyLimit] scans IA par mois calendaire.
///   • Pro  : illimité (fair-use serveur via worker Cloudflare).
///
/// Un « scan IA » agrège OCR + embedding + auto-tag + résumé. C'est le bundle
/// qui coûte ~$0,002 côté OpenAI — pas le simple stockage d'une carte.
///
/// Le compteur `monthlyGenerationCount` est porté par
/// [SubscriptionSnapshotEntity] (déjà persisté côté ObjectBox via
/// `SubscriptionRepository.incrementMonthlyGeneration`). Ce service s'appuie
/// dessus — il n'introduit pas un second compteur.
abstract interface class ScanQuotaService {
  /// Nombre de scans IA gratuits par mois.
  static const int freeMonthlyLimit = 15;

  /// Seuil à partir duquel on affiche l'avertissement "tu approches la limite".
  static const int freeWarningThreshold = 12;

  /// Vérifie si le prochain scan est autorisé.
  ///
  /// `isPro` est injecté par l'appelant pour éviter un aller-retour au repo.
  Future<ScanDecision> evaluate({required bool isPro});

  /// Signale au service qu'un scan vient d'être consommé. No-op en Pro.
  Future<void> consume({required bool isPro});
}

/// Décision renvoyée par [ScanQuotaService.evaluate].
sealed class ScanDecision {
  const ScanDecision();

  /// Le scan peut se lancer.
  ///
  /// [remaining] est null si Pro (illimité), sinon le nombre de scans restants
  /// pour le mois en cours (peut valoir 0 si ce scan sera le dernier du quota).
  const factory ScanDecision.allowed({int? remaining}) = ScanAllowed;

  /// Le scan doit être bloqué. L'UI affiche un paywall contextuel.
  const factory ScanDecision.blocked({
    required ScanBlockedReason reason,
  }) = ScanBlocked;

  /// Le scan est autorisé mais on avertit le user — il approche de la limite.
  const factory ScanDecision.warning({
    required int remaining,
  }) = ScanWarning;
}

final class ScanAllowed extends ScanDecision {
  const ScanAllowed({this.remaining});
  final int? remaining;
}

final class ScanBlocked extends ScanDecision {
  const ScanBlocked({required this.reason});
  final ScanBlockedReason reason;
}

final class ScanWarning extends ScanDecision {
  const ScanWarning({required this.remaining});
  final int remaining;
}

enum ScanBlockedReason { monthlyLimitReached }
