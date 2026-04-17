import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/data/services/auth_service.impl.dart';
import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/domain/services/auth.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service d'authentification (singleton — Firebase Auth gère son propre cache).
final Provider<AuthService> authServiceProvider = Provider<AuthService>((
  Ref ref,
) {
  return FirebaseAuthService(
    analytics: ref.watch(analyticsServiceProvider),
  );
});

/// Stream des changements d'état auth — émet immédiatement la valeur courante
/// puis chaque login/logout/token-refresh.
final StreamProvider<AuthUserEntity?> authStateProvider =
    StreamProvider<AuthUserEntity?>((Ref ref) {
      return ref.watch(authServiceProvider).authStateChanges();
    });

/// Accès synchrone à l'utilisateur courant (nullable). Utilisé par le gating
/// paywall et les widgets de Settings — lit la dernière valeur émise par
/// `authStateProvider` sans bloquer sur un `AsyncValue`.
final Provider<AuthUserEntity?> currentUserProvider = Provider<AuthUserEntity?>(
  (Ref ref) {
    return ref.watch(authStateProvider).value;
  },
);
