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
    this.onboardingCompletedAt,
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

  @Property(type: PropertyType.date)
  DateTime? onboardingCompletedAt;
}
