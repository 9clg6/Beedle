/// Exception métier générique pour l'app.
class BeedleException implements Exception {
  const BeedleException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() => 'BeedleException: $message${cause != null ? ' (cause: $cause)' : ''}';
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
