import 'package:beedle/domain/entities/activity_day.entity.dart';
import 'package:beedle/domain/entities/gamification_state.entity.dart';
import 'package:beedle/domain/entities/weekly_challenge.entity.dart';
import 'package:beedle/domain/repositories/gamification.repository.dart';
import 'package:beedle/foundation/interfaces/future.usecases.dart';

/// Résultat groupé pour l'UI dashboard.
class GamificationDashboard {
  const GamificationDashboard({
    required this.state,
    required this.last84Days,
    required this.currentChallenge,
  });

  final GamificationStateEntity state;
  final List<ActivityDayEntity> last84Days; // 12 semaines pour activity graph
  final WeeklyChallengeEntity? currentChallenge;
}

final class GetGamificationDashboardUseCase extends FutureUseCase<GamificationDashboard> {
  GetGamificationDashboardUseCase({required GamificationRepository gamificationRepository})
      : _repo = gamificationRepository;

  final GamificationRepository _repo;

  @override
  Future<GamificationDashboard> invoke() async {
    final state = await _repo.loadState();
    final days = await _repo.last(84);
    final challenge = await _repo.currentChallenge();
    return GamificationDashboard(
      state: state,
      last84Days: days,
      currentChallenge: challenge,
    );
  }
}
