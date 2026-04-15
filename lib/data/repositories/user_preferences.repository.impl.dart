import 'package:beedle/data/datasources/local/user_preferences.local.data_source.dart';
import 'package:beedle/data/mappers/user_preferences.mapper.dart';
import 'package:beedle/data/model/local/user_preferences.local.model.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/repositories/user_preferences.repository.dart';

final class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  UserPreferencesRepositoryImpl({required UserPreferencesLocalDataSource dataSource})
      : _dataSource = dataSource;

  final UserPreferencesLocalDataSource _dataSource;

  @override
  Future<UserPreferencesEntity> load() async {
    final local = await _dataSource.load();
    return local.toEntity();
  }

  @override
  Future<void> save(UserPreferencesEntity prefs) async {
    await _dataSource.save(prefs.toLocalModel());
  }

  @override
  Stream<UserPreferencesEntity> watch() {
    return _dataSource.watch().map((m) => m.toEntity());
  }
}
