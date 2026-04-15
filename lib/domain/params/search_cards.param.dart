import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_cards.param.freezed.dart';

/// Paramètres pour une recherche sémantique.
@Freezed(copyWith: true)
abstract class SearchCardsParam with _$SearchCardsParam {
  const factory SearchCardsParam({
    required String query,
    @Default(10) int limit,
    @Default(false) bool restrictToCurrentMonth,
  }) = _SearchCardsParam;
}
