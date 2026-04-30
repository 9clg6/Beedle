import 'dart:async';

import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/core/providers/usecase_providers.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/params/search_cards.param.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/features/search/presentation/screens/search.state.dart';
import 'package:beedle/foundation/interfaces/results.usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search.view_model.g.dart';

@riverpod
class SearchViewModel extends _$SearchViewModel {
  Timer? _debounce;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return SearchState.initial();
  }

  void updateQuery(String value) {
    state = state.copyWith(query: value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _runSearch);
  }

  Future<void> _runSearch() async {
    if (state.query.trim().isEmpty) {
      state = state.copyWith(results: <CardEntity>[], isSearching: false);
      return;
    }
    state = state.copyWith(isSearching: true);

    final SubscriptionSnapshotEntity sub = await ref
        .read(subscriptionRepositoryProvider)
        .load();

    final ResultState<List<CardEntity>> result = await ref
        .read(searchCardsUseCaseProvider)
        .execute(
          SearchCardsParam(
            query: state.query,
            restrictToCurrentMonth: !sub.isPro,
          ),
        );

    final List<CardEntity> results = result.data ?? <CardEntity>[];
    state = state.copyWith(results: results, isSearching: false);

    await ref
        .read(analyticsServiceProvider)
        .track(
          AnalyticsEvent.searchRun,
          properties: <String, Object>{
            'query_len': state.query.length,
            'result_count': results.length,
            'pro': sub.isPro,
          },
        );
  }
}
