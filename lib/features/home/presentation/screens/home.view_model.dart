import 'package:beedle/core/providers/usecase_providers.dart';
import 'package:beedle/domain/usecases/get_home_cards.use_case.dart';
import 'package:beedle/features/home/presentation/screens/home.state.dart';
import 'package:beedle/foundation/interfaces/results.usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home.view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  Future<HomeState> build() async {
    return _fetch();
  }

  Future<HomeState> _fetch() async {
    final GetHomeCardsUseCase useCase = ref.read(getHomeCardsUseCaseProvider);
    final ResultState<HomeCardsResult> result = await useCase.execute();
    return result.when<HomeState>(
          success: (HomeCardsResult data) => HomeState(
            suggestion: data.suggestion,
            rewatch: data.rewatch,
            totalCards: data.totalCards,
          ),
          failure: (Exception e) => HomeState.initial(),
        ) ??
        HomeState.initial();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<HomeState>();
    state = await AsyncValue.guard<HomeState>(_fetch);
  }
}
