import 'package:beedle/core/providers/usecase_providers.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/features/card_detail/presentation/screens/card_detail.state.dart';
import 'package:beedle/foundation/interfaces/results.usecases.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'card_detail.view_model.g.dart';

@riverpod
class CardDetailViewModel extends _$CardDetailViewModel {
  @override
  Future<CardDetailState> build(String uuid) async {
    return _load(uuid);
  }

  Future<CardDetailState> _load(String uuid) async {
    final ResultState<CardEntity?> result = await ref
        .read(getCardUseCaseProvider)
        .execute(uuid);
    final CardEntity? card = result.data;
    if (card != null) {
      await ref.read(markCardViewedUseCaseProvider).execute(uuid);
    }
    return CardDetailState(card: card);
  }

  Future<void> markTested() async {
    final String? uuid = state.value?.card?.uuid;
    if (uuid == null) return;
    await ref.read(markCardTestedUseCaseProvider).execute(uuid);
    state = await AsyncValue.guard<CardDetailState>(() => _load(uuid));
  }

  Future<void> deleteCard() async {
    final String? uuid = state.value?.card?.uuid;
    if (uuid == null) return;
    await ref.read(deleteCardUseCaseProvider).execute(uuid);
  }

  void setCodeCopied(bool copied) {
    final CardDetailState? current = state.value;
    if (current == null) return;
    state = AsyncData<CardDetailState>(current.copyWith(codeCopied: copied));
  }
}
