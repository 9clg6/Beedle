import 'package:beedle/core/providers/auth.provider.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/domain/services/auth.service.dart';
import 'package:beedle/features/auth/presentation/screens/auth.screen.dart' show AuthScreen;
import 'package:beedle/features/auth/presentation/screens/auth.state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.view_model.g.dart';

/// View model de [AuthScreen] — orchestre les flows signin Google/Apple/skip.
///
/// Toute la logique reste ici (pas dans le widget). Le widget watch
/// `state.status` pour brancher les loaders.
@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthScreenState build() => const AuthScreenState();

  Future<bool> signInWithGoogle() => _signIn(
    provider: 'google',
    pendingStatus: AuthScreenStatus.signingInGoogle,
    op: () => ref.read(authServiceProvider).signInWithGoogle(),
  );

  Future<bool> signInWithApple() => _signIn(
    provider: 'apple',
    pendingStatus: AuthScreenStatus.signingInApple,
    op: () => ref.read(authServiceProvider).signInWithApple(),
  );

  /// Marque l'utilisateur comme ayant choisi le mode anonyme. Persisté dans
  /// `UserPreferences.authSkippedAt` pour éviter de re-pousser l'AuthScreen
  /// à chaque relance.
  Future<void> skip() async {
    final UserPreferencesEntity prefs = await ref
        .read(userPreferencesRepositoryProvider)
        .load();
    await ref
        .read(userPreferencesRepositoryProvider)
        .save(prefs.copyWith(authSkippedAt: DateTime.now()));
    await ref
        .read(analyticsServiceProvider)
        .track(AnalyticsEvent.authSigninSkipped);
  }

  // ── Internal ────────────────────────────────────────────────────────

  Future<bool> _signIn({
    required String provider,
    required AuthScreenStatus pendingStatus,
    required Future<AuthUserEntity> Function() op,
  }) async {
    state = state.copyWith(status: pendingStatus, error: null);
    final AnalyticsService analytics = ref.read(analyticsServiceProvider);
    await analytics.track(
      AnalyticsEvent.authSigninStarted,
      properties: <String, Object>{'provider': provider},
    );
    try {
      final AuthUserEntity user = await op();
      await analytics.track(
        AnalyticsEvent.authSigninSucceeded,
        properties: <String, Object>{'provider': provider},
      );
      await ref.read(crashReporterServiceProvider).setUserIdentifier(user.uid);
      state = state.copyWith(status: AuthScreenStatus.success);
      return true;
    } on AuthCancelledByUser {
      state = state.copyWith(status: AuthScreenStatus.idle);
      return false;
    } on AuthFailure catch (e) {
      await analytics.track(
        AnalyticsEvent.authSigninFailed,
        properties: <String, Object>{
          'provider': provider,
          'reason': e.message,
        },
      );
      state = state.copyWith(status: AuthScreenStatus.idle, error: e);
      return false;
    }
  }
}
