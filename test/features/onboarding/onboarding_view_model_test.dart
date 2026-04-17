import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/enum/onboarding_goal.enum.dart';
import 'package:beedle/domain/enum/pain_point.enum.dart';
import 'package:beedle/domain/repositories/user_preferences.repository.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUserPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

ProviderContainer _buildContainer({
  UserPreferencesRepository? prefsRepo,
  AnalyticsService? analytics,
}) {
  return ProviderContainer(
    overrides: <Override>[
      if (prefsRepo != null)
        userPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
      if (analytics != null)
        analyticsServiceProvider.overrideWithValue(analytics),
    ],
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(UserPreferencesEntity.initial());
  });

  group('OnboardingViewModel — navigation', () {
    test('next() advances by one until index 14 (caps at last screen)', () {
      final ProviderContainer c = _buildContainer();
      addTearDown(c.dispose);
      final OnboardingViewModel vm = c.read(
        onboardingViewModelProvider.notifier,
      );

      for (int i = 0; i < 14; i++) {
        vm.next();
      }
      expect(c.read(onboardingViewModelProvider).currentIndex, 14);

      // Cap — extra next() must not overflow.
      vm.next();
      expect(c.read(onboardingViewModelProvider).currentIndex, 14);
    });

    test('previous() does not go below 0', () {
      final ProviderContainer c = _buildContainer();
      addTearDown(c.dispose);
      final OnboardingViewModel vm = c.read(
        onboardingViewModelProvider.notifier,
      );

      vm.previous();
      expect(c.read(onboardingViewModelProvider).currentIndex, 0);
    });

    test('goTo() jumps to arbitrary index', () {
      final ProviderContainer c = _buildContainer();
      addTearDown(c.dispose);
      final OnboardingViewModel vm = c.read(
        onboardingViewModelProvider.notifier,
      );

      vm.goTo(7);
      expect(c.read(onboardingViewModelProvider).currentIndex, 7);
    });
  });

  group('OnboardingViewModel — self-discovery', () {
    test('selectGoal() persists chosen goal', () {
      final ProviderContainer c = _buildContainer();
      addTearDown(c.dispose);
      c
          .read(onboardingViewModelProvider.notifier)
          .selectGoal(OnboardingGoal.buildFaster);

      expect(
        c.read(onboardingViewModelProvider).goal,
        OnboardingGoal.buildFaster,
      );
    });

    test('togglePainPoint() adds then removes a pain point', () {
      final ProviderContainer c = _buildContainer();
      addTearDown(c.dispose);
      final OnboardingViewModel vm = c.read(
        onboardingViewModelProvider.notifier,
      );

      vm.togglePainPoint(PainPoint.reGoogle);
      expect(
        c.read(onboardingViewModelProvider).painPoints,
        <PainPoint>{PainPoint.reGoogle},
      );

      vm.togglePainPoint(PainPoint.reGoogle);
      expect(c.read(onboardingViewModelProvider).painPoints, isEmpty);
    });

    test('togglePainPoint() supports multi-select', () {
      final ProviderContainer c = _buildContainer();
      addTearDown(c.dispose);
      final OnboardingViewModel vm = c.read(
        onboardingViewModelProvider.notifier,
      );

      vm
        ..togglePainPoint(PainPoint.reGoogle)
        ..togglePainPoint(PainPoint.notionHeavy);

      expect(
        c.read(onboardingViewModelProvider).painPoints,
        <PainPoint>{PainPoint.reGoogle, PainPoint.notionHeavy},
      );
    });

    test('recordTinderSwipe() tracks only agreed indices', () {
      final ProviderContainer c = _buildContainer();
      addTearDown(c.dispose);
      final OnboardingViewModel vm = c.read(
        onboardingViewModelProvider.notifier,
      );

      vm
        ..recordTinderSwipe(0, agreed: true)
        ..recordTinderSwipe(1, agreed: false)
        ..recordTinderSwipe(2, agreed: true);

      expect(
        c.read(onboardingViewModelProvider).tinderAgreedIndices,
        <int>{0, 2},
      );
    });

    test('recordTinderSwipe() removes index when re-swiped left', () {
      final ProviderContainer c = _buildContainer();
      addTearDown(c.dispose);
      final OnboardingViewModel vm = c.read(
        onboardingViewModelProvider.notifier,
      );

      vm
        ..recordTinderSwipe(0, agreed: true)
        ..recordTinderSwipe(0, agreed: false);

      expect(
        c.read(onboardingViewModelProvider).tinderAgreedIndices,
        isEmpty,
      );
    });
  });

  group('OnboardingViewModel — demo', () {
    test('markDemoCompleted() flips the flag idempotently', () {
      final ProviderContainer c = _buildContainer();
      addTearDown(c.dispose);
      final OnboardingViewModel vm = c.read(
        onboardingViewModelProvider.notifier,
      );

      expect(c.read(onboardingViewModelProvider).demoCompleted, isFalse);
      vm.markDemoCompleted();
      expect(c.read(onboardingViewModelProvider).demoCompleted, isTrue);
      // Idempotent — second call doesn't toggle.
      vm.markDemoCompleted();
      expect(c.read(onboardingViewModelProvider).demoCompleted, isTrue);
    });
  });

  group('OnboardingViewModel — finishOnboarding', () {
    test('persists prefs and tracks analytics with full payload', () async {
      final _MockUserPreferencesRepository prefsRepo =
          _MockUserPreferencesRepository();
      final _MockAnalyticsService analytics = _MockAnalyticsService();

      when(() => prefsRepo.save(any())).thenAnswer((_) async {});
      when(
        () => analytics.track(any(), properties: any(named: 'properties')),
      ).thenAnswer((_) async {});

      final ProviderContainer c = _buildContainer(
        prefsRepo: prefsRepo,
        analytics: analytics,
      );
      addTearDown(c.dispose);
      final OnboardingViewModel vm = c.read(
        onboardingViewModelProvider.notifier,
      );

      vm
        ..selectGoal(OnboardingGoal.stayAIUpToDate)
        ..togglePainPoint(PainPoint.reGoogle)
        ..togglePainPoint(PainPoint.notionHeavy)
        ..markDemoCompleted();

      await vm.finishOnboarding();

      verify(() => prefsRepo.save(any())).called(1);

      final VerificationResult capture = verify(
        () => analytics.track(
          AnalyticsEvent.onboardingCompleted,
          properties: captureAny(named: 'properties'),
        ),
      )..called(1);
      final Map<String, Object> payload =
          capture.captured.single as Map<String, Object>;

      expect(payload['goal'], 'stayAIUpToDate');
      expect(payload['pain_points_count'], 2);
      expect(payload['demo_completed'], isTrue);
    });

    test('clears isSubmitting when complete', () async {
      final _MockUserPreferencesRepository prefsRepo =
          _MockUserPreferencesRepository();
      final _MockAnalyticsService analytics = _MockAnalyticsService();

      when(() => prefsRepo.save(any())).thenAnswer((_) async {});
      when(
        () => analytics.track(any(), properties: any(named: 'properties')),
      ).thenAnswer((_) async {});

      final ProviderContainer c = _buildContainer(
        prefsRepo: prefsRepo,
        analytics: analytics,
      );
      addTearDown(c.dispose);
      final OnboardingViewModel vm = c.read(
        onboardingViewModelProvider.notifier,
      );

      await vm.finishOnboarding();

      expect(c.read(onboardingViewModelProvider).isSubmitting, isFalse);
    });
  });
}
