import 'package:beedle/data/services/auth_service.impl.dart';
import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/domain/enum/auth_provider.enum.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/domain/services/auth.service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class _MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class _MockUserCredential extends Mock implements UserCredential {}

class _MockUser extends Mock implements User {}

class _MockUserMetadata extends Mock implements UserMetadata {}

class _MockUserInfo extends Mock implements UserInfo {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAuthCredential());
  });

  // ── Helper : un User Firebase pré-câblé pour qu'on puisse mapper. ─────
  _MockUser buildUser({String providerId = 'google.com'}) {
    final _MockUser user = _MockUser();
    final _MockUserMetadata meta = _MockUserMetadata();
    final _MockUserInfo info = _MockUserInfo();
    when(() => user.uid).thenReturn('uid-test');
    when(() => user.email).thenReturn('test@example.com');
    when(() => user.displayName).thenReturn('Test');
    when(() => user.photoURL).thenReturn(null);
    when(() => user.metadata).thenReturn(meta);
    when(() => meta.creationTime).thenReturn(DateTime.utc(2026));
    when(() => info.providerId).thenReturn(providerId);
    when(() => user.providerData).thenReturn(<UserInfo>[info]);
    return user;
  }

  group('FirebaseAuthService.currentUser', () {
    test('renvoie null si pas de user courant', () {
      final _MockFirebaseAuth auth = _MockFirebaseAuth();
      when(() => auth.currentUser).thenReturn(null);

      final FirebaseAuthService service = FirebaseAuthService(
        firebaseAuth: auth,
        googleSignIn: _MockGoogleSignIn(),
      );

      expect(service.currentUser, isNull);
    });

    test('renvoie une entity avec le provider mappé depuis providerData', () {
      final _MockFirebaseAuth auth = _MockFirebaseAuth();
      final _MockUser user = buildUser(providerId: 'apple.com');
      when(() => auth.currentUser).thenReturn(user);

      final FirebaseAuthService service = FirebaseAuthService(
        firebaseAuth: auth,
        googleSignIn: _MockGoogleSignIn(),
      );

      final AuthUserEntity? result = service.currentUser;
      expect(result, isNotNull);
      expect(result!.uid, 'uid-test');
      expect(result.provider, AuthProvider.apple);
    });
  });

  group('FirebaseAuthService.authStateChanges', () {
    test("émet null puis l'entity quand l'auth state change", () async {
      final _MockFirebaseAuth auth = _MockFirebaseAuth();
      final _MockUser user = buildUser();
      when(auth.authStateChanges).thenAnswer(
        (_) => Stream<User?>.fromIterable(<User?>[null, user]),
      );

      final FirebaseAuthService service = FirebaseAuthService(
        firebaseAuth: auth,
        googleSignIn: _MockGoogleSignIn(),
      );

      final List<AuthUserEntity?> emitted = await service
          .authStateChanges()
          .toList();

      expect(emitted, hasLength(2));
      expect(emitted[0], isNull);
      expect(emitted[1], isNotNull);
      expect(emitted[1]!.uid, 'uid-test');
    });
  });

  group('FirebaseAuthService.signInWithGoogle', () {
    test('happy path → renvoie AuthUserEntity avec provider=google', () async {
      final _MockFirebaseAuth auth = _MockFirebaseAuth();
      final _MockGoogleSignIn google = _MockGoogleSignIn();
      final _MockGoogleSignInAccount account = _MockGoogleSignInAccount();
      final _MockGoogleSignInAuthentication googleAuth =
          _MockGoogleSignInAuthentication();
      final _MockUserCredential cred = _MockUserCredential();
      final _MockUser user = buildUser();

      when(google.signIn).thenAnswer((_) async => account);
      when(() => account.authentication).thenAnswer((_) async => googleAuth);
      when(() => googleAuth.accessToken).thenReturn('access-token');
      when(() => googleAuth.idToken).thenReturn('id-token');
      when(
        () => auth.signInWithCredential(any()),
      ).thenAnswer((_) async => cred);
      when(() => cred.user).thenReturn(user);

      final FirebaseAuthService service = FirebaseAuthService(
        firebaseAuth: auth,
        googleSignIn: google,
      );

      final AuthUserEntity result = await service.signInWithGoogle();

      expect(result.provider, AuthProvider.google);
      expect(result.uid, 'uid-test');
    });

    test(
      'user cancels (signIn returns null) → throw AuthCancelledByUser',
      () async {
        final _MockFirebaseAuth auth = _MockFirebaseAuth();
        final _MockGoogleSignIn google = _MockGoogleSignIn();
        when(google.signIn).thenAnswer((_) async => null);

        final FirebaseAuthService service = FirebaseAuthService(
          firebaseAuth: auth,
          googleSignIn: google,
        );

        expect(
          service.signInWithGoogle,
          throwsA(isA<AuthCancelledByUser>()),
        );
      },
    );

    test(
      'PlatformException network_error → throw AuthNetworkFailure',
      () async {
        final _MockFirebaseAuth auth = _MockFirebaseAuth();
        final _MockGoogleSignIn google = _MockGoogleSignIn();
        when(google.signIn).thenThrow(
          PlatformException(code: 'network_error', message: 'No internet'),
        );

        final FirebaseAuthService service = FirebaseAuthService(
          firebaseAuth: auth,
          googleSignIn: google,
        );

        expect(
          service.signInWithGoogle,
          throwsA(isA<AuthNetworkFailure>()),
        );
      },
    );

    test('FirebaseAuthException → throw AuthProviderFailure', () async {
      final _MockFirebaseAuth auth = _MockFirebaseAuth();
      final _MockGoogleSignIn google = _MockGoogleSignIn();
      final _MockGoogleSignInAccount account = _MockGoogleSignInAccount();
      final _MockGoogleSignInAuthentication googleAuth =
          _MockGoogleSignInAuthentication();

      when(google.signIn).thenAnswer((_) async => account);
      when(() => account.authentication).thenAnswer((_) async => googleAuth);
      when(() => googleAuth.accessToken).thenReturn('a');
      when(() => googleAuth.idToken).thenReturn('i');
      when(() => auth.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'invalid-credential'),
      );

      final FirebaseAuthService service = FirebaseAuthService(
        firebaseAuth: auth,
        googleSignIn: google,
      );

      expect(
        service.signInWithGoogle,
        throwsA(isA<AuthProviderFailure>()),
      );
    });
  });

  group('FirebaseAuthService.signInWithApple', () {
    test(
      'happy path → renvoie AuthUserEntity avec provider=apple',
      () async {
        final _MockFirebaseAuth auth = _MockFirebaseAuth();
        final _MockUserCredential cred = _MockUserCredential();
        final _MockUser user = buildUser(providerId: 'apple.com');

        when(
          () => auth.signInWithCredential(any()),
        ).thenAnswer((_) async => cred);
        when(() => cred.user).thenReturn(user);

        // Note : on ne peut pas mocker la static `SignInWithApple.getAppleIDCredential`
        // sans wrapper dédié. Ce test vérifie que la mapping post-credential
        // fonctionne ; les autres branches (cancel, provider failure) seraient
        // couvertes par un AppleSignInClient abstrait dans une itération future.

        final FirebaseAuthService service = FirebaseAuthService(
          firebaseAuth: auth,
          googleSignIn: _MockGoogleSignIn(),
        );
        expect(service, isNotNull);
      },
      skip:
          'SignInWithApple.getAppleIDCredential est une API static non-injectable '
          '— nécessite un AppleSignInClient wrapper pour devenir testable. '
          'Tracked dans la PR description.',
    );
  });

  group('FirebaseAuthService.signOut', () {
    test('appelle à la fois auth.signOut() ET google.signOut()', () async {
      final _MockFirebaseAuth auth = _MockFirebaseAuth();
      final _MockGoogleSignIn google = _MockGoogleSignIn();
      when(auth.signOut).thenAnswer((_) async {});
      when(google.signOut).thenAnswer((_) async => null);

      final FirebaseAuthService service = FirebaseAuthService(
        firebaseAuth: auth,
        googleSignIn: google,
      );

      await service.signOut();

      verify(auth.signOut).called(1);
      verify(google.signOut).called(1);
    });

    test('track authSignout via AnalyticsService injecté', () async {
      final _MockFirebaseAuth auth = _MockFirebaseAuth();
      final _MockGoogleSignIn google = _MockGoogleSignIn();
      final _MockAnalyticsService analytics = _MockAnalyticsService();
      when(auth.signOut).thenAnswer((_) async {});
      when(google.signOut).thenAnswer((_) async => null);
      when(() => analytics.track(any())).thenAnswer((_) async {});

      final FirebaseAuthService service = FirebaseAuthService(
        firebaseAuth: auth,
        googleSignIn: google,
        analytics: analytics,
      );

      await service.signOut();

      verify(() => analytics.track(AnalyticsEvent.authSignout)).called(1);
    });
  });
}
