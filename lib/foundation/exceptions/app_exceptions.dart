/// Exception métier générique pour l'app.
class BeedleException implements Exception {
  const BeedleException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() =>
      'BeedleException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// Échec d'appel au LLM (timeout, rate limit, 5xx...).
class LLMException extends BeedleException {
  const LLMException(super.message, {super.cause, this.statusCode});
  final int? statusCode;
}

/// OCR a renvoyé un résultat trop faible ou vide.
class OCRFailureException extends BeedleException {
  const OCRFailureException(super.message, {super.cause});
}

/// Quota freemium atteint.
class FreemiumCapReachedException extends BeedleException {
  const FreemiumCapReachedException() : super('Monthly freemium cap reached');
}

/// Permission OS refusée.
class PermissionDeniedException extends BeedleException {
  const PermissionDeniedException(this.permission, {super.cause})
    : super('Permission denied: $permission');
  final String permission;
}

/// Toutes les captures sélectionnées sont déjà présentes en base (même
/// SHA-256). Levée par `ImportScreenshotsUseCase` pour que la UI affiche
/// un message clair ("Ces captures ont déjà été importées") au lieu du
/// toString() technique.
class AllDuplicatesException extends BeedleException {
  const AllDuplicatesException()
    : super('All selected screenshots are already imported.');
}
