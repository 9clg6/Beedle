import 'package:beedle/domain/entities/user_preferences.entity.dart';

abstract interface class UserPreferencesRepository {
  Future<UserPreferencesEntity> load();

  Future<void> save(UserPreferencesEntity prefs);

  Stream<UserPreferencesEntity> watch();
}
