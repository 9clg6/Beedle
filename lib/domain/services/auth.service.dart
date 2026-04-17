import 'package:beedle/domain/entities/auth_user.entity.dart';

/// Contrat du service d'authentification (impl via Firebase Auth dans la
/// couche data — voir `FirebaseAuthService`).
///
/// La couche presentation ne référence JAMAIS directement `firebase_auth`,
/// `google_sign_in` ou `sign_in_with_apple` : tout passe par cette interface.
abstract interface class AuthService {
  /// Stream des changements d'état auth (login / logout / token refresh).
  Stream<AuthUserEntity?> authStateChanges();

  /// Utilisateur courant (synchrone, depuis le cache local Firebase).
  AuthUserEntity? get currentUser;

  /// Lance le flow Sign in with Google (sheet natif iOS/Android).
  ///
  /// Throws :
  /// - [AuthCancelledByUser] si l'utilisateur ferme le sheet
  /// - [AuthNetworkFailure] si la couche réseau a échoué
  /// - [AuthProviderFailure] si Firebase ou le SDK Google a refusé le credential
  Future<AuthUserEntity> signInWithGoogle();

  /// Lance le flow Sign in with Apple (sheet natif iOS, OAuth web sur Android).
  ///
  /// Throws : mêmes erreurs que [signInWithGoogle].
  Future<AuthUserEntity> signInWithApple();

  /// Déconnecte l'utilisateur de Firebase ET du provider OAuth (Google).
  Future<void> signOut();
}

/// Erreurs typées que l'impl peut throw, pour que le view_model branche
/// proprement (loader → idle vs loader → error).
sealed class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}

/// L'utilisateur a fermé le sheet d'auth (ou refusé sur Apple).
final class AuthCancelledByUser extends AuthFailure {
  const AuthCancelledByUser() : super('Authentication cancelled by user');
}

/// Erreur réseau lors de l'auth (timeout, offline, DNS…).
final class AuthNetworkFailure extends AuthFailure {
  const AuthNetworkFailure(super.message);
}

/// Erreur côté provider OAuth ou Firebase (credential refusé, compte
/// existant avec un autre provider, etc.).
final class AuthProviderFailure extends AuthFailure {
  const AuthProviderFailure(super.message);
}
