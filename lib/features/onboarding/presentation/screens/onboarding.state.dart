import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding.state.freezed.dart';

@Freezed(copyWith: true)
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentIndex,
    @Default(<ContentCategory>[]) List<ContentCategory> contentCategories,
    @Default(1) int teaserCountPerDay,
    @Default(20) int captureReminderHour,
    @Default(false) bool notificationsGranted,
    @Default(false) bool photosGranted,
    @Default(false) bool isSubmitting,
  }) = _OnboardingState;

  factory OnboardingState.initial() => const OnboardingState();
}
