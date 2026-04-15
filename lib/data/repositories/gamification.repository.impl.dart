import 'package:beedle/data/datasources/local/gamification.local.data_source.dart';
import 'package:beedle/data/mappers/gamification.mapper.dart';
import 'package:beedle/data/model/local/activity_day.local.model.dart';
import 'package:beedle/data/model/local/gamification_state.local.model.dart';
import 'package:beedle/data/model/local/weekly_challenge.local.model.dart';
import 'package:beedle/domain/entities/activity_day.entity.dart';
import 'package:beedle/domain/entities/gamification_state.entity.dart';
import 'package:beedle/domain/entities/weekly_challenge.entity.dart';
import 'package:beedle/domain/repositories/gamification.repository.dart';

final class GamificationRepositoryImpl implements GamificationRepository {
  GamificationRepositoryImpl({required GamificationLocalDataSource dataSource})
      : _dataSource = dataSource;

  final GamificationLocalDataSource _dataSource;

  @override
  Future<GamificationStateEntity> loadState() async {
    final local = await _dataSource.loadState();
    return local.toEntity();
  }

  @override
  Future<void> saveState(GamificationStateEntity state) async {
    await _dataSource.saveState(state.toLocalModel());
  }

  @override
  Stream<GamificationStateEntity> watchState() {
    return _dataSource.watchState().map((m) => m.toEntity());
  }

  @override
  Future<ActivityDayEntity> todayActivity() async {
    final today = _todayMidnight();
    final local = await _dataSource.activityForDay(today);
    return local?.toEntity() ?? ActivityDayEntity(day: today);
  }

  @override
  Future<void> upsertActivity(ActivityDayEntity day) async {
    await _dataSource.upsertActivity(day.toLocalModel());
  }

  @override
  Future<List<ActivityDayEntity>> last(int days) async {
    final list = await _dataSource.lastDays(days);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<WeeklyChallengeEntity?> currentChallenge() async {
    final weekStart = _currentWeekStart();
    final local = await _dataSource.challengeByWeekStart(weekStart);
    return local?.toEntity();
  }

  @override
  Future<void> saveChallenge(WeeklyChallengeEntity challenge) async {
    await _dataSource.saveChallenge(challenge.toLocalModel());
  }

  @override
  Future<void> wipe() => _dataSource.wipe();

  DateTime _todayMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _currentWeekStart() {
    final today = _todayMidnight();
    // weekday = 1..7 (lundi..dimanche)
    return today.subtract(Duration(days: today.weekday - 1));
  }
}
