import 'package:objectbox/objectbox.dart';

@Entity()
class UserPreferencesLocalModel {
  UserPreferencesLocalModel({
    this.id = 1, // singleton
    this.contentCategoriesJson = '[]',
    this.teaserCountPerDay = 1,
    this.captureReminderHour = 20,
    this.uiLanguage = 'system',
    this.themeMode = 'system',
    this.analyticsConsent = true,
    this.autoImportEnabled = true,
    this.voiceTerminalEnabled = true,
    this.voicePushEnabled = true,
    this.voicePushQuotaPerDay = 1,
    this.voiceZenMode = false,
    this.dailyLessonPushEnabled = false,
    this.dailyLessonHour = 9,
    this.onboardingCompletedAt,
    this.authSkippedAt,
  });

  @Id(assignable: true)
  int id;

  String contentCategoriesJson;
  int teaserCountPerDay;
  int captureReminderHour;
  String uiLanguage;
  String themeMode;
  bool analyticsConsent;
  bool autoImportEnabled;

  // Beedle's Voice settings.
  bool voiceTerminalEnabled;
  bool voicePushEnabled;
  int voicePushQuotaPerDay;
  bool voiceZenMode;

  // Daily Lesson settings.
  bool dailyLessonPushEnabled;
  int dailyLessonHour;

  @Property(type: PropertyType.date)
  DateTime? onboardingCompletedAt;

  /// Marqueur "l'utilisateur a choisi de ne pas s'authentifier" — voir
  /// `UserPreferencesEntity.authSkippedAt`.
  @Property(type: PropertyType.date)
  DateTime? authSkippedAt;
}
