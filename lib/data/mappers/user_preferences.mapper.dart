import 'dart:convert';

import 'package:beedle/data/model/local/user_preferences.local.model.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/enum/content_category.enum.dart';

extension UserPreferencesLocalModelX on UserPreferencesLocalModel {
  UserPreferencesEntity toEntity() {
    final cats = (jsonDecode(contentCategoriesJson) as List<dynamic>)
        .map((dynamic e) => ContentCategory.fromString(e.toString()))
        .toList();
    return UserPreferencesEntity(
      contentCategories: cats,
      teaserCountPerDay: teaserCountPerDay,
      captureReminderHour: captureReminderHour,
      uiLanguage: uiLanguage,
      themeMode: themeMode,
      analyticsConsent: analyticsConsent,
      autoImportEnabled: autoImportEnabled,
      onboardingCompletedAt: onboardingCompletedAt,
    );
  }
}

extension UserPreferencesEntityToLocalX on UserPreferencesEntity {
  UserPreferencesLocalModel toLocalModel() => UserPreferencesLocalModel(
        contentCategoriesJson: jsonEncode(contentCategories.map((c) => c.name).toList()),
        teaserCountPerDay: teaserCountPerDay,
        captureReminderHour: captureReminderHour,
        uiLanguage: uiLanguage,
        themeMode: themeMode,
        analyticsConsent: analyticsConsent,
        autoImportEnabled: autoImportEnabled,
        onboardingCompletedAt: onboardingCompletedAt,
      );
}
