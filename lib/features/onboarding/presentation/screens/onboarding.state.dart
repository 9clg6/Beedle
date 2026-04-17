import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:beedle/domain/enum/onboarding_goal.enum.dart';
import 'package:beedle/domain/enum/pain_point.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding.state.freezed.dart';

@Freezed(copyWith: true)
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentIndex,
    // Self-discovery (questionnaire)
    OnboardingGoal? goal,
    @Default(<PainPoint>{}) Set<PainPoint> painPoints,
    @Default(<int>{}) Set<int> tinderAgreedIndices,
    // Demo (interactive simulation — user has tapped "digest" once)
    @Default(false) bool demoCompleted,
    // Legacy: kept for backwards-compat with the old Tinder-demo
    // (deprecated, no longer driven by the UI but still in the analytics
    // payload until the next analytics schema change).
    @Default(<int>{}) Set<int> demoSwipedRightIndices,
    // Preferences (existing — unchanged)
    @Default(<ContentCategory>[]) List<ContentCategory> contentCategories,
    @Default(1) int teaserCountPerDay,
    @Default(20) int captureReminderHour,
    // Permissions (existing — unchanged)
    @Default(false) bool notificationsGranted,
    @Default(false) bool photosGranted,
    // Submission (existing — unchanged)
    @Default(false) bool isSubmitting,
  }) = _OnboardingState;

  factory OnboardingState.initial() => const OnboardingState();
}
