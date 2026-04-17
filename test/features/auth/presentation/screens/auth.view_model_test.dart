import 'package:beedle/core/providers/auth.provider.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/enum/auth_provider.enum.dart';
import 'package:beedle/domain/repositories/user_preferences.repository.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/domain/services/auth.service.dart';
import 'package:beedle/domain/services/crash_reporter.service.dart';
import 'package:beedle/features/auth/presentation/screens/auth.state.dart';
import 'package:beedle/features/auth/presentation/screens/auth.view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockUserPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

class _FakeCrashReporter implements CrashReporterService {
  @override
  Future<void> setUserIdentifier(String uid) async {}
}

ProviderContainer _buildContainer({
  required AuthService authService,
  required AnalyticsService analytics,
  UserPreferencesRepository? prefsRepo,
}) {
  return ProviderContainer(
    overrides: <Override>[
      authServiceProvider.overrideWithValue(authService),
      analyticsServiceProvider.overrideWithValue(analytics),
      crashReporterServiceProvider.overrideWithValue(_FakeCrashReporter()),
      if (prefsRepo != null)
        userPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
    ],
  );
}

AuthUserEntity _entity({
  String uid = 'uid-1',
  AuthProvider provider = AuthProvider.google,
}) => AuthUserEntity(
  uid: uid,
  provider: provider,
  createdAt: DateTime.utc(2026, 1, 1),
);

void main() {
  setUpAll(() {
    registerFallbackValue(UserPreferencesEntity.initial());
  });

  group('AuthViewModel.signInWithGoogle', () {
    test('happy → status passe par signingInGoogle puis success', () async {
      final _MockAuthService auth = _MockAuthService();
      final _MockAnalyticsService analytics = _MockAnalyticsService();

      when(() => auth.signInWithGoogle()).thenAnswer((_) async => _entity());
      when(
        () => analytics.track(any(), properties: any(named: 'properties')),
      ).thenAnswer((_) async {});

      final ProviderContainer c = _buildContainer(
        authService: auth,
        analytics: analytics,
      );
      addTearDown(c.dispose);

      final List<AuthScreenStatus> statuses = <AuthScreenStatus>[
        c.read(authViewModelProvider).status,
      ];
      c.listen<AuthScreenState>(
        authViewModelProvider,
        (AuthScreenState? prev, AuthScreenState next) =>
            statuses.add(next.status),
      );

      final bool ok = await c
          .read(authViewModelProvider.notifier)
          .signInWithGoogle();

      expect(ok, isTrue);
      expect(statuses, contains(AuthScreenStatus.signingInGoogle));
      expect(statuses.last, AuthScreenStatus.success);
    });

    test('cancelled → status revient à idle, error reste null', () async {
      final _MockAuthService auth = _MockAuthService();
      final _MockAnalyticsService analytics = _MockAnalyticsService();

      when(
        () => auth.signInWithGoogle(),
      ).thenThrow(const AuthCancelledByUser());
      when(
        () => analytics.track(any(), properties: any(named: 'properties')),
      ).thenAnswer((_) async {});

      final ProviderContainer c = _buildContainer(
        authService: auth,
        analytics: analytics,
      );
      addTearDown(c.dispose);

      final bool ok = await c
          .read(authViewModelProvider.notifier)
          .signInWithGoogle();

      expect(ok, isFalse);
      final AuthScreenState state = c.read(authViewModelProvider);
      expect(state.status, AuthScreenStatus.idle);
      expect(state.error, isNull);
    });

    test('AuthFailure → status = idle, error = failure', () async {
      final _MockAuthService auth = _MockAuthService();
      final _MockAnalyticsService analytics = _MockAnalyticsService();

      when(
        () => auth.signInWithGoogle(),
      ).thenThrow(const AuthNetworkFailure('boom'));
      when(
        () => analytics.track(any(), properties: any(named: 'properties')),
      ).thenAnswer((_) async {});

      final ProviderContainer c = _buildContainer(
        authService: auth,
        analytics: analytics,
      );
      addTearDown(c.dispose);

      final bool ok = await c
          .read(authViewModelProvider.notifier)
          .signInWithGoogle();

      expect(ok, isFalse);
      final AuthScreenState state = c.read(authViewModelProvider);
      expect(state.status, AuthScreenStatus.idle);
      expect(state.error, isA<AuthNetworkFailure>());
    });
  });

  group('AuthViewModel.signInWithApple', () {
    test('happy → status passe par signingInApple puis success', () async {
      final _MockAuthService auth = _MockAuthService();
      final _MockAnalyticsService analytics = _MockAnalyticsService();

      when(
        () => auth.signInWithApple(),
      ).thenAnswer((_) async => _entity(provider: AuthProvider.apple));
      when(
        () => analytics.track(any(), properties: any(named: 'properties')),
      ).thenAnswer((_) async {});

      final ProviderContainer c = _buildContainer(
        authService: auth,
        analytics: analytics,
      );
      addTearDown(c.dispose);

      final List<AuthScreenStatus> statuses = <AuthScreenStatus>[];
      c.listen<AuthScreenState>(
        authViewModelProvider,
        (AuthScreenState? prev, AuthScreenState next) =>
            statuses.add(next.status),
      );

      final bool ok = await c
          .read(authViewModelProvider.notifier)
          .signInWithApple();

      expect(ok, isTrue);
      expect(statuses, contains(AuthScreenStatus.signingInApple));
      expect(statuses.last, AuthScreenStatus.success);
    });

    test('cancelled → status revient à idle, error reste null', () async {
      final _MockAuthService auth = _MockAuthService();
      final _MockAnalyticsService analytics = _MockAnalyticsService();

      when(() => auth.signInWithApple()).thenThrow(const AuthCancelledByUser());
      when(
        () => analytics.track(any(), properties: any(named: 'properties')),
      ).thenAnswer((_) async {});

      final ProviderContainer c = _buildContainer(
        authService: auth,
        analytics: analytics,
      );
      addTearDown(c.dispose);

      final bool ok = await c
          .read(authViewModelProvider.notifier)
          .signInWithApple();

      expect(ok, isFalse);
      final AuthScreenState state = c.read(authViewModelProvider);
      expect(state.status, AuthScreenStatus.idle);
      expect(state.error, isNull);
    });

    test('AuthFailure → status = idle, error = failure', () async {
      final _MockAuthService auth = _MockAuthService();
      final _MockAnalyticsService analytics = _MockAnalyticsService();

      when(
        () => auth.signInWithApple(),
      ).thenThrow(const AuthProviderFailure('apple:invalid-credential'));
      when(
        () => analytics.track(any(), properties: any(named: 'properties')),
      ).thenAnswer((_) async {});

      final ProviderContainer c = _buildContainer(
        authService: auth,
        analytics: analytics,
      );
      addTearDown(c.dispose);

      final bool ok = await c
          .read(authViewModelProvider.notifier)
          .signInWithApple();

      expect(ok, isFalse);
      final AuthScreenState state = c.read(authViewModelProvider);
      expect(state.status, AuthScreenStatus.idle);
      expect(state.error, isA<AuthProviderFailure>());
    });
  });

  group('AuthViewModel.skip', () {
    test('persiste authSkippedAt dans UserPreferences', () async {
      final _MockAuthService auth = _MockAuthService();
      final _MockAnalyticsService analytics = _MockAnalyticsService();
      final _MockUserPreferencesRepository prefsRepo =
          _MockUserPreferencesRepository();

      when(prefsRepo.load).thenAnswer(
        (_) async => UserPreferencesEntity.initial(),
      );
      when(() => prefsRepo.save(any())).thenAnswer((_) async {});
      when(
        () => analytics.track(any(), properties: any(named: 'properties')),
      ).thenAnswer((_) async {});

      final ProviderContainer c = _buildContainer(
        authService: auth,
        analytics: analytics,
        prefsRepo: prefsRepo,
      );
      addTearDown(c.dispose);

      await c.read(authViewModelProvider.notifier).skip();

      final VerificationResult capture = verify(
        () => prefsRepo.save(captureAny()),
      )..called(1);
      final UserPreferencesEntity saved =
          capture.captured.single as UserPreferencesEntity;
      expect(saved.authSkippedAt, isNotNull);

      verify(
        () => analytics.track(AnalyticsEvent.authSigninSkipped),
      ).called(1);
    });
  });
}
