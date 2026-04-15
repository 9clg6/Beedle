import 'package:beedle/domain/entities/card.entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_detail.state.freezed.dart';

@Freezed(copyWith: true)
abstract class CardDetailState with _$CardDetailState {
  const factory CardDetailState({
    CardEntity? card,
    @Default(false) bool codeCopied,
  }) = _CardDetailState;

  factory CardDetailState.initial() => const CardDetailState();
}
