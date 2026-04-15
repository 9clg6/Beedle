import 'package:beedle/domain/enum/content_category.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences.entity.freezed.dart';

/// Entité préférences utilisateur — singleton persisté en ObjectBox.
@freezed
abstract class UserPreferencesEntity with _$UserPreferencesEntity {
  const factory UserPreferencesEntity({
    @Default(<ContentCategory>[]) List<ContentCategory> contentCategories,
    @Default(1) int teaserCountPerDay,
    @Default(20) int captureReminderHour,
    @Default('system') String uiLanguage, // 'fr' | 'en' | 'system'
    @Default('system') String themeMode, // 'light' | 'dark' | 'system'
    @Default(true) bool analyticsConsent,
    @Default(true) bool autoImportEnabled,
    DateTime? onboardingCompletedAt,
  }) = _UserPreferencesEntity;

  factory UserPreferencesEntity.initial() => const UserPreferencesEntity();
}

extension UserPreferencesEntityX on UserPreferencesEntity {
  bool get hasCompletedOnboarding => onboardingCompletedAt != null;
}
