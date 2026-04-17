import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/data/model/local/activity_day.local.model.dart';
import 'package:beedle/data/model/local/gamification_state.local.model.dart';
import 'package:beedle/data/model/local/weekly_challenge.local.model.dart';
import 'package:beedle/objectbox.g.dart';

abstract interface class GamificationLocalDataSource {
  Future<GamificationStateLocalModel> loadState();
  Future<void> saveState(GamificationStateLocalModel state);
  Stream<GamificationStateLocalModel> watchState();

  Future<ActivityDayLocalModel?> activityForDay(DateTime dayMidnight);
  Future<void> upsertActivity(ActivityDayLocalModel day);
  Future<List<ActivityDayLocalModel>> lastDays(int count);

  Future<WeeklyChallengeLocalModel?> challengeByWeekStart(DateTime weekStart);
  Future<void> saveChallenge(WeeklyChallengeLocalModel challenge);

  Future<void> wipe();
}

final class GamificationLocalDataSourceImpl
    implements GamificationLocalDataSource {
  GamificationLocalDataSourceImpl({required ObjectBoxStore store})
    : _store = store;

  final ObjectBoxStore _store;

  Box<GamificationStateLocalModel> get _stateBox =>
      _store.store.box<GamificationStateLocalModel>();
  Box<ActivityDayLocalModel> get _activityBox =>
      _store.store.box<ActivityDayLocalModel>();
  Box<WeeklyChallengeLocalModel> get _challengeBox =>
      _store.store.box<WeeklyChallengeLocalModel>();

  @override
  Future<GamificationStateLocalModel> loadState() async {
    final GamificationStateLocalModel? existing = _stateBox.get(1);
    if (existing != null) return existing;
    final GamificationStateLocalModel initial = GamificationStateLocalModel();
    _stateBox.put(initial);
    return initial;
  }

  @override
  Future<void> saveState(GamificationStateLocalModel state) async {
    state.id = 1;
    _stateBox.put(state);
  }

  @override
  Stream<GamificationStateLocalModel> watchState() {
    return _stateBox.query().watch(triggerImmediately: true).map((
      Query<GamificationStateLocalModel> query,
    ) {
      return query.findFirst() ?? GamificationStateLocalModel();
    });
  }

  @override
  Future<ActivityDayLocalModel?> activityForDay(DateTime dayMidnight) async {
    final Query<ActivityDayLocalModel> q = _activityBox
        .query(ActivityDayLocalModel_.dayEpoch.equalsDate(dayMidnight))
        .build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  @override
  Future<void> upsertActivity(ActivityDayLocalModel day) async {
    final ActivityDayLocalModel? existing = await activityForDay(day.dayEpoch);
    if (existing != null) day.id = existing.id;
    _activityBox.put(day);
  }

  @override
  Future<List<ActivityDayLocalModel>> lastDays(int count) async {
    final Query<ActivityDayLocalModel> q = _activityBox
        .query()
        .order(ActivityDayLocalModel_.dayEpoch, flags: Order.descending)
        .build();
    try {
      q.limit = count;
      return q.find();
    } finally {
      q.close();
    }
  }

  @override
  Future<WeeklyChallengeLocalModel?> challengeByWeekStart(
    DateTime weekStart,
  ) async {
    final Query<WeeklyChallengeLocalModel> q = _challengeBox
        .query(WeeklyChallengeLocalModel_.weekStart.equalsDate(weekStart))
        .build();
    try {
      return q.findFirst();
    } finally {
      q.close();
    }
  }

  @override
  Future<void> saveChallenge(WeeklyChallengeLocalModel challenge) async {
    final WeeklyChallengeLocalModel? existing = await challengeByWeekStart(
      challenge.weekStart,
    );
    if (existing != null) challenge.id = existing.id;
    _challengeBox.put(challenge);
  }

  @override
  Future<void> wipe() async {
    _stateBox.removeAll();
    _activityBox.removeAll();
    _challengeBox.removeAll();
  }
}
