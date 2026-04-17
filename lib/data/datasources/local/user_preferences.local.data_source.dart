import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/data/model/local/user_preferences.local.model.dart';
import 'package:beedle/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

abstract interface class UserPreferencesLocalDataSource {
  Future<UserPreferencesLocalModel> load();
  Future<void> save(UserPreferencesLocalModel prefs);
  Stream<UserPreferencesLocalModel> watch();
  Future<void> wipe();
}

final class UserPreferencesLocalDataSourceImpl
    implements UserPreferencesLocalDataSource {
  UserPreferencesLocalDataSourceImpl({required ObjectBoxStore store})
    : _store = store;

  final ObjectBoxStore _store;

  Box<UserPreferencesLocalModel> get _box =>
      _store.store.box<UserPreferencesLocalModel>();

  @override
  Future<UserPreferencesLocalModel> load() async {
    final UserPreferencesLocalModel? existing = _box.get(1);
    if (existing != null) return existing;
    final UserPreferencesLocalModel initial = UserPreferencesLocalModel();
    _box.put(initial);
    return initial;
  }

  @override
  Future<void> save(UserPreferencesLocalModel prefs) async {
    prefs.id = 1;
    _box.put(prefs);
  }

  @override
  Stream<UserPreferencesLocalModel> watch() {
    return _box.query().watch(triggerImmediately: true).map((
      Query<UserPreferencesLocalModel> query,
    ) {
      final UserPreferencesLocalModel? first = query.findFirst();
      return first ?? UserPreferencesLocalModel();
    });
  }

  @override
  Future<void> wipe() async {
    _box.removeAll();
  }
}
