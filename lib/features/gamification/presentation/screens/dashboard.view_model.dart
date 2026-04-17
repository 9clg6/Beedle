import 'package:beedle/core/providers/usecase_providers.dart';
import 'package:beedle/domain/usecases/get_gamification_dashboard.use_case.dart';
import 'package:beedle/features/gamification/presentation/screens/dashboard.state.dart';
import 'package:beedle/foundation/interfaces/results.usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard.view_model.g.dart';

@riverpod
class DashboardViewModel extends _$DashboardViewModel {
  @override
  Future<DashboardState> build() async {
    final ResultState<GamificationDashboard> result = await ref
        .read(getGamificationDashboardUseCaseProvider)
        .execute();
    final GamificationDashboard? data = result.data;
    if (data == null) return DashboardState.initial();
    return DashboardState(
      state: data.state,
      days: data.last84Days,
      currentChallenge: data.currentChallenge,
    );
  }
}
