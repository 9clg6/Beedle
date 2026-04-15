import 'package:beedle/domain/entities/card.entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home.state.freezed.dart';

@Freezed(copyWith: true)
abstract class HomeState with _$HomeState {
  const factory HomeState({
    required List<CardEntity> rewatch,
    @Default(0) int totalCards,
    @Default(false) bool isRefreshing,
    CardEntity? suggestion,
  }) = _HomeState;

  factory HomeState.initial() => const HomeState(rewatch: <CardEntity>[]);
}
