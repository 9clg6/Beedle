import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Future<void> requestNotifications() async {
    final bool granted = await ref
        .read(localNotificationEngineInterfaceProvider)
        .requestPermission();
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
    state = state.copyWith(photosGranted: granted);
  }

  Future<void> finishOnboarding() async {
    state = state.copyWith(isSubmitting: true);
    final UserPreferencesEntity prefs = UserPreferencesEntity(
      contentCategories: state.contentCategories,
      teaserCountPerDay: state.teaserCountPerDay,
      captureReminderHour: state.captureReminderHour,
      onboardingCompletedAt: DateTime.now(),
    );
    await ref.read(userPreferencesRepositoryProvider).save(prefs);
    state = state.copyWith(isSubmitting: false);
  }
}
