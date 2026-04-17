import 'package:beedle/data/mappers/auth_user.mapper.dart';
import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/domain/enum/auth_provider.enum.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/domain/services/auth.service.dart';
import 'package:beedle/foundation/logging/logger.dart';
// `firebase_auth` exporte aussi un type `AuthProvider`. On le cache pour
// éviter le conflit avec notre enum domain.
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Implémentation [AuthService] via Firebase Auth + Google Sign-In + Sign in
/// with Apple.
///
/// Aucune fuite de PII : on logue `uid` uniquement (jamais token / email /
/// refresh token).
final class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    AnalyticsService? analytics,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _google = googleSignIn ?? GoogleSignIn(scopes: const <String>['email']),
       _analytics = analytics;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  final AnalyticsService? _analytics;
  final Log _log = Log.named('FirebaseAuthService');

  @override
  AuthUserEntity? get currentUser {
    final User? user = _auth.currentUser;
    if (user == null) return null;
    return user.toEntity(provider: authProviderOf(user));
  }

  @override
  Stream<AuthUserEntity?> authStateChanges() {
    return _auth.authStateChanges().map((User? user) {
      if (user == null) return null;
      return user.toEntity(provider: authProviderOf(user));
    });
  }

  @override
  Future<AuthUserEntity> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? google = await _google.signIn();
      if (google == null) {
        throw const AuthCancelledByUser();
      }
      final GoogleSignInAuthentication auth = await google.authentication;
      final OAuthCredential cred = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final UserCredential result = await _auth.signInWithCredential(cred);
      final User user = result.user!;
      _log.info('Google sign-in succeeded uid=${user.uid}');
      return user.toEntity(provider: AuthProvider.google);
    } on FirebaseAuthException catch (e) {
      throw AuthProviderFailure('Firebase: ${e.code}');
    } on PlatformException catch (e) {
      throw AuthNetworkFailure('Platform: ${e.code}');
    }
  }

  @override
  Future<AuthUserEntity> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID apple =
          await SignInWithApple.getAppleIDCredential(
            scopes: const <AppleIDAuthorizationScopes>[
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );
      final OAuthCredential cred = OAuthProvider('apple.com').credential(
        idToken: apple.identityToken,
        accessToken: apple.authorizationCode,
      );
      final UserCredential result = await _auth.signInWithCredential(cred);
      final User user = result.user!;

      // Apple ne renvoie givenName/familyName qu'à la 1ère connexion. On le
      // persiste sur le user Firebase pour qu'il soit dispo aux relances.
      if (apple.givenName != null && user.displayName == null) {
        final String fullName = '${apple.givenName} ${apple.familyName ?? ''}'
            .trim();
        await user.updateDisplayName(fullName);
        await user.reload();
      }

      _log.info('Apple sign-in succeeded uid=${user.uid}');
      return user.toEntity(provider: AuthProvider.apple);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthCancelledByUser();
      }
      throw AuthProviderFailure('Apple: ${e.code.name}');
    } on FirebaseAuthException catch (e) {
      throw AuthProviderFailure('Firebase: ${e.code}');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait<void>(<Future<void>>[
      _auth.signOut(),
      _google.signOut(),
    ]);
    await _analytics?.track(AnalyticsEvent.authSignout);
    _log.info('Signed out');
  }
}
