import 'package:beedle/domain/entities/card.entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search.state.freezed.dart';

@Freezed(copyWith: true)
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String query,
    @Default(<CardEntity>[]) List<CardEntity> results,
    @Default(false) bool isSearching,
  }) = _SearchState;

  factory SearchState.initial() => const SearchState();
}
