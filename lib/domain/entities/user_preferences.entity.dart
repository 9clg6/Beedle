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
    // ── Beedle's Voice (engagement layer) ─────────────────────────────
    @Default(true) bool voiceTerminalEnabled,
    @Default(true) bool voicePushEnabled,
    @Default(1) int voicePushQuotaPerDay, // 0..3
    @Default(false) bool voiceZenMode, // kill-switch total
    // ── Daily Lesson ──────────────────────────────────────────────────
    @Default(false) bool dailyLessonPushEnabled, // opt-in push matinal
    @Default(9) int dailyLessonHour, // 0..23 ; default 9h
    DateTime? onboardingCompletedAt,
    // ── Auth ──────────────────────────────────────────────────────────
    /// Marqueur explicite "l'utilisateur a choisi le mode anonyme" — permet
    /// au splash de skipper l'AuthScreen aux relances suivantes.
    DateTime? authSkippedAt,
  }) = _UserPreferencesEntity;

  factory UserPreferencesEntity.initial() => const UserPreferencesEntity();
}

extension UserPreferencesEntityX on UserPreferencesEntity {
  bool get hasCompletedOnboarding => onboardingCompletedAt != null;
}
