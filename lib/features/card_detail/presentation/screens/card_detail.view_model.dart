import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/core/providers/usecase_providers.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/screenshot.entity.dart';
import 'package:beedle/domain/services/analytics.service.dart';
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
    List<ScreenshotEntity> screenshots = const <ScreenshotEntity>[];
    if (card != null) {
      await ref.read(markCardViewedUseCaseProvider).execute(uuid);
      screenshots = await ref
          .read(screenshotRepositoryProvider)
          .getByCardUuid(uuid);
      await ref
          .read(analyticsServiceProvider)
          .track(
            AnalyticsEvent.cardOpened,
            properties: <String, Object>{
              'card_uuid': uuid,
              'intent': card.intent.name,
              'language': card.language,
              'viewed_count': card.viewedCount,
            },
          );
    }
    return CardDetailState(card: card, screenshots: screenshots);
  }

  Future<void> markTested() async {
    final String? uuid = state.value?.card?.uuid;
    if (uuid == null) return;
    await ref.read(markCardTestedUseCaseProvider).execute(uuid);
    await ref
        .read(analyticsServiceProvider)
        .track(
          AnalyticsEvent.cardMarkedTested,
          properties: <String, Object>{'card_uuid': uuid},
        );
    state = await AsyncValue.guard<CardDetailState>(() => _load(uuid));
  }

  Future<void> deleteCard() async {
    final String? uuid = state.value?.card?.uuid;
    if (uuid == null) return;
    await ref.read(deleteCardUseCaseProvider).execute(uuid);
    await ref
        .read(analyticsServiceProvider)
        .track(
          AnalyticsEvent.cardDeleted,
          properties: <String, Object>{'card_uuid': uuid},
        );
  }

  void setCodeCopied(bool copied) {
    final CardDetailState? current = state.value;
    if (current == null) return;
    state = AsyncData<CardDetailState>(current.copyWith(codeCopied: copied));
  }
}
