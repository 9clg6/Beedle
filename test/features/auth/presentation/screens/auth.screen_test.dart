import 'package:beedle/core/providers/auth.provider.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/repositories/user_preferences.repository.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/domain/services/auth.service.dart';
import 'package:beedle/domain/services/crash_reporter.service.dart';
import 'package:beedle/features/auth/presentation/screens/auth.screen.dart';
import 'package:beedle/features/auth/presentation/widgets/auth_provider_button.dart';
import 'package:flutter/material.dart';
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

Widget _wrap({
  required AuthService authService,
  required AnalyticsService analytics,
  required UserPreferencesRepository prefsRepo,
  bool required = false,
}) {
  return ProviderScope(
    overrides: <Override>[
      authServiceProvider.overrideWithValue(authService),
      analyticsServiceProvider.overrideWithValue(analytics),
      userPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      crashReporterServiceProvider.overrideWithValue(_FakeCrashReporter()),
    ],
    child: MaterialApp(home: AuthScreen(required: required)),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(UserPreferencesEntity.initial());
  });

  late _MockAuthService auth;
  late _MockAnalyticsService analytics;
  late _MockUserPreferencesRepository prefsRepo;

  setUp(() {
    auth = _MockAuthService();
    analytics = _MockAnalyticsService();
    prefsRepo = _MockUserPreferencesRepository();
    when(
      () => analytics.track(any(), properties: any(named: 'properties')),
    ).thenAnswer((_) async {});
    when(prefsRepo.load).thenAnswer(
      (_) async => UserPreferencesEntity.initial(),
    );
    when(() => prefsRepo.save(any())).thenAnswer((_) async {});
  });

  testWidgets(
    'required=false → affiche les 2 boutons signin + le bouton skip',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          authService: auth,
          analytics: analytics,
          prefsRepo: prefsRepo,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AuthProviderButton), findsNWidgets(2));
      expect(find.byType(TextButton), findsOneWidget);
    },
  );

  testWidgets(
    "required=true → n'affiche PAS le bouton skip",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          authService: auth,
          analytics: analytics,
          prefsRepo: prefsRepo,
          required: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AuthProviderButton), findsNWidgets(2));
      expect(find.byType(TextButton), findsNothing);
    },
  );

  testWidgets(
    'tap sur le bouton Apple → appelle signInWithApple du service',
    (WidgetTester tester) async {
      // On fait throw `AuthCancelledByUser` pour court-circuiter la navigation
      // au retour (qui requiert un AutoRouter), tout en validant que le tap
      // appelle bien le service.
      when(() => auth.signInWithApple()).thenThrow(const AuthCancelledByUser());

      await tester.pumpWidget(
        _wrap(
          authService: auth,
          analytics: analytics,
          prefsRepo: prefsRepo,
          required: true,
        ),
      );
      await tester.pumpAndSettle();

      // Le 1er bouton dans le layout est Apple (cf. ordre dans auth.screen.dart).
      final Finder appleButton = find.byType(AuthProviderButton).first;
      await tester.tap(appleButton);
      await tester.pump();

      verify(() => auth.signInWithApple()).called(1);
    },
  );
}
