import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/domain/enum/auth_provider.enum.dart';
import 'package:beedle/foundation/logging/logger.dart';
// `firebase_auth` exporte aussi un type `AuthProvider`. On le cache pour
// éviter le conflit avec notre enum domain.
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

final Log _log = Log.named('AuthUserMapper');

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
/// Fallback safe : [AuthProvider.google] (le plus commun) ; un providerId
/// inconnu est loggé en warn pour faciliter le debug des mismatches analytics.
AuthProvider authProviderOf(User user) {
  final String? id = user.providerData.isNotEmpty
      ? user.providerData.first.providerId
      : null;
  switch (id) {
    case 'apple.com':
      return AuthProvider.apple;
    case 'google.com':
      return AuthProvider.google;
    default:
      _log.warn(
        'Unknown providerId="$id" — defaulting to AuthProvider.google',
      );
      return AuthProvider.google;
  }
}
