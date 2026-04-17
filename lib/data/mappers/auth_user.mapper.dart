import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/domain/enum/auth_provider.enum.dart';
// `firebase_auth` exporte aussi un type `AuthProvider`. On le cache pour
// éviter le conflit avec notre enum domain.
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

/// Mappe un [User] Firebase vers l'entité domain [AuthUserEntity].
extension FirebaseUserMapperX on User {
  AuthUserEntity toEntity({required AuthProvider provider}) {
    return AuthUserEntity(
      uid: uid,
      provider: provider,
      createdAt: metadata.creationTime ?? DateTime.now(),
      email: email,
      displayName: displayName,
      photoUrl: photoURL,
    );
  }
}

/// Détermine le [AuthProvider] depuis `User.providerData[0].providerId`
/// — Firebase n'expose pas le provider de la session courante directement.
/// Fallback safe : [AuthProvider.google] (le plus commun).
AuthProvider authProviderOf(User user) {
  final String? id = user.providerData.isNotEmpty
      ? user.providerData.first.providerId
      : null;
  return switch (id) {
    'apple.com' => AuthProvider.apple,
    'google.com' => AuthProvider.google,
    _ => AuthProvider.google,
  };
}
