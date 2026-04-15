import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding.view_model.g.dart';

@riverpod
class OnboardingViewModel extends _$OnboardingViewModel {
  @override
  OnboardingState build() => OnboardingState.initial();

  void next() {
    if (state.currentIndex < 11) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previous() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void goTo(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void toggleCategory(ContentCategory c) {
    final updated = List<ContentCategory>.of(state.contentCategories);
    if (updated.contains(c)) {
      updated.remove(c);
    } else {
      updated.add(c);
    }
    state = state.copyWith(contentCategories: updated);
  }

  void setTeaserCount(int count) => state = state.copyWith(teaserCountPerDay: count);

  void setReminderHour(int hour) => state = state.copyWith(captureReminderHour: hour);

  Future<void> requestNotifications() async {
    final granted = await ref.read(localNotificationEngineInterfaceProvider).requestPermission();
    state = state.copyWith(notificationsGranted: granted);
  }

  void markPhotosGranted() {
    // L'autorisation Photos est demandée au moment du picker (ne s'affiche
    // pas comme un modal Dart ici). On enregistre le soft-ask comme passé.
    state = state.copyWith(photosGranted: true);
  }

  Future<void> finishOnboarding() async {
    state = state.copyWith(isSubmitting: true);
    final prefs = UserPreferencesEntity(
      contentCategories: state.contentCategories,
      teaserCountPerDay: state.teaserCountPerDay,
      captureReminderHour: state.captureReminderHour,
      onboardingCompletedAt: DateTime.now(),
    );
    await ref.read(userPreferencesRepositoryProvider).save(prefs);
    state = state.copyWith(isSubmitting: false);
  }
}
