import 'dart:async';

import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:beedle/domain/enum/onboarding_goal.enum.dart';
import 'package:beedle/domain/enum/pain_point.enum.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/features/onboarding/data/onboarding_baked_cards.provider.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding_step_validator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding.view_model.g.dart';

@riverpod
class OnboardingViewModel extends _$OnboardingViewModel {
  @override
  OnboardingState build() => OnboardingState.initial();

  void next() {
    if (state.currentIndex < kOnboardingLastIndex) {
      final int from = state.currentIndex;
      final int to = from + 1;
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .track(
              AnalyticsEvent.onboardingStepCompleted,
              properties: <String, Object>{'from': from, 'to': to},
            ),
      );
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .track(
              AnalyticsEvent.onboardingStepViewed,
              properties: <String, Object>{'step': to},
            ),
      );
      state = state.copyWith(currentIndex: to);
    }
  }

  void previous() {
    if (state.currentIndex > 0) {
      final int from = state.currentIndex;
      final int to = from - 1;
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .track(
              AnalyticsEvent.onboardingStepBack,
              properties: <String, Object>{'from': from, 'to': to},
            ),
      );
      state = state.copyWith(currentIndex: to);
    }
  }

  void goTo(int index) {
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .track(
            AnalyticsEvent.onboardingStepViewed,
            properties: <String, Object>{'step': index},
          ),
    );
    state = state.copyWith(currentIndex: index);
  }

  // ── Self-discovery setters ───────────────────────────────────────────

  void selectGoal(OnboardingGoal goal) {
    state = state.copyWith(goal: goal);
  }

  void togglePainPoint(PainPoint point) {
    final Set<PainPoint> updated = <PainPoint>{...state.painPoints};
    if (!updated.add(point)) {
      updated.remove(point);
    }
    state = state.copyWith(painPoints: updated);
  }

  void recordTinderSwipe(int index, {required bool agreed}) {
    final Set<int> updated = <int>{...state.tinderAgreedIndices};
    if (agreed) {
      updated.add(index);
    } else {
      updated.remove(index);
    }
    state = state.copyWith(tinderAgreedIndices: updated);
  }

  // ── Demo (écran 13) ─────────────────────────────────────────────────

  /// Marqueur "l'utilisateur a tapé sur le bouton *Digérer ce screenshot*
  /// au moins une fois" — débloque la sortie de l'écran de démo simulée.
  void markDemoCompleted() {
    if (state.demoCompleted) return;
    state = state.copyWith(demoCompleted: true);
  }

  /// Deprecated — l'ancien Tinder-demo n'existe plus. Conservé pour ne
  /// pas casser les tests legacy. À supprimer dans le prochain refactor
  /// state.
  void recordDemoSwipe(int index, {required bool keep}) {
    final Set<int> updated = <int>{...state.demoSwipedRightIndices};
    if (keep) {
      updated.add(index);
    } else {
      updated.remove(index);
    }
    state = state.copyWith(demoSwipedRightIndices: updated);
  }

  // ── Preferences (existing) ───────────────────────────────────────────

  void toggleCategory(ContentCategory c) {
    final List<ContentCategory> updated = List<ContentCategory>.of(
      state.contentCategories,
    );
    if (updated.contains(c)) {
      updated.remove(c);
    } else {
      updated.add(c);
    }
    state = state.copyWith(contentCategories: updated);
  }

  void setTeaserCount(int count) =>
      state = state.copyWith(teaserCountPerDay: count);

  void setReminderHour(int hour) =>
      state = state.copyWith(captureReminderHour: hour);

  // ── Permissions (existing) ───────────────────────────────────────────

  Future<void> requestNotifications() async {
    final bool granted = await ref
        .read(localNotificationEngineInterfaceProvider)
        .requestPermission();
    await ref
        .read(analyticsServiceProvider)
        .track(
          granted
              ? AnalyticsEvent.permissionGranted
              : AnalyticsEvent.permissionDenied,
          properties: <String, Object>{'permission': 'notifications'},
        );
    state = state.copyWith(notificationsGranted: granted);
  }

  /// Demande la permission OS pour accéder à la pellicule. Déclenche le
  /// prompt natif iOS/Android via `permission_handler`. Un refus ou un
  /// "limited" est quand même traité comme "granted côté soft-ask" pour
  /// que l'utilisateur puisse avancer dans l'onboarding — iOS limited
  /// autorise quand même l'image_picker à afficher les photos
  /// sélectionnées par l'utilisateur.
  Future<void> requestPhotos() async {
    final PermissionStatus status = await Permission.photos.request();
    final bool granted =
        status.isGranted || status.isLimited || status.isProvisional;
    await ref
        .read(analyticsServiceProvider)
        .track(
          granted
              ? AnalyticsEvent.permissionGranted
              : AnalyticsEvent.permissionDenied,
          properties: <String, Object>{
            'permission': 'photos',
            'status': status.name,
          },
        );
    state = state.copyWith(photosGranted: granted);
  }

  // ── Finish ──────────────────────────────────────────────────────────

  Future<void> finishOnboarding() async {
    state = state.copyWith(isSubmitting: true);
    try {
      final UserPreferencesEntity prefs = UserPreferencesEntity(
        contentCategories: state.contentCategories,
        teaserCountPerDay: state.teaserCountPerDay,
        captureReminderHour: state.captureReminderHour,
        onboardingCompletedAt: DateTime.now(),
      );
      await ref.read(userPreferencesRepositoryProvider).save(prefs);

      // Persiste les 3 fiches baked en bibliothèque (idempotent grâce
      // aux UUID v5 déterministes) — l'utilisateur arrive sur Home avec
      // sa "mini-bibliothèque" déjà peuplée. Best-effort : si le call
      // embedding échoue (offline), l'onboarding ne crashe pas et la
      // Home affiche l'empty state habituel.
      final int persistedCount = await ref
          .read(onboardingBakedCardsRepositoryProvider)
          .persistAll();

      // Analytics — payload aligné sur §4.14 du blueprint.
      await ref
          .read(analyticsServiceProvider)
          .track(
            AnalyticsEvent.onboardingCompleted,
            properties: <String, Object>{
              'goal': state.goal?.name ?? 'unknown',
              'pain_points_count': state.painPoints.length,
              'categories': state.contentCategories
                  .map((ContentCategory c) => c.name)
                  .join(','),
              'teaser_count': state.teaserCountPerDay,
              'photos_granted': state.photosGranted,
              'notifications_granted': state.notificationsGranted,
              'demo_completed': state.demoCompleted,
              'baked_cards_persisted': persistedCount,
            },
          );
    } finally {
      // Always reset isSubmitting — even on save / track failure — so a
      // retry from the paywall CTA isn't blocked by a stuck spinner.
      state = state.copyWith(isSubmitting: false);
    }
  }
}
