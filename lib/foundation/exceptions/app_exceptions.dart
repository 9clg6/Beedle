/// Exception métier générique pour l'app.
///
/// `message` est le détail technique (loggé, envoyé à Crashlytics).
/// `userMessage` est le texte à afficher à l'utilisateur final — en français,
/// sans jargon, actionnable. Par défaut, il vaut `message` pour que les
/// exceptions legacy restent compatibles.
class BeedleException implements Exception {
  const BeedleException(this.message, {this.cause, String? userMessage})
    : _userMessage = userMessage;
  final String message;
  final Object? cause;
  final String? _userMessage;

  String get userMessage => _userMessage ?? message;

  @override
  String toString() =>
      'BeedleException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// Échec d'appel au LLM (timeout, rate limit, 5xx, réponse tronquée,
/// JSON corrompu...). `kind` permet à l'UI/au crash reporter de distinguer
/// les cas — utile aussi pour le retry (certains cas ne sont pas retryables).
enum LLMErrorKind {
  truncated,
  invalidJson,
  rateLimited,
  quotaExhausted,
  network,
  server,
  empty,
  unknown,
}

class LLMException extends BeedleException {
  const LLMException(
    super.message, {
    super.cause,
    super.userMessage,
    this.statusCode,
    this.kind = LLMErrorKind.unknown,
  });
  final int? statusCode;
  final LLMErrorKind kind;
}

/// OCR a renvoyé un résultat trop faible ou vide.
class OCRFailureException extends BeedleException {
  const OCRFailureException(super.message, {super.cause, super.userMessage});
}

/// Quota freemium atteint.
class FreemiumCapReachedException extends BeedleException {
  const FreemiumCapReachedException()
    : super(
        'Monthly freemium cap reached',
        userMessage:
            'Quota mensuel atteint. Passe en Pro pour continuer à importer.',
      );
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
    : super(
        'All selected screenshots are already imported.',
        userMessage: 'Ces captures ont déjà été importées.',
      );
}
