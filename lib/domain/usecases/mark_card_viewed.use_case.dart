import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/domain/services/gamification_engine.service.dart';
import 'package:beedle/foundation/interfaces/future.usecases.dart';

final class MarkCardViewedUseCase
    extends FutureUseCaseWithParams<void, String> {
  MarkCardViewedUseCase({
    required CardRepository cardRepository,
    required GamificationEngine gamificationEngine,
  }) : _cardRepository = cardRepository,
       _gamificationEngine = gamificationEngine;

  final CardRepository _cardRepository;
  final GamificationEngine _gamificationEngine;

  @override
  Future<void> invoke(String cardUuid) async {
    await _cardRepository.markViewed(cardUuid);
    final CardEntity? card = await _cardRepository.getByUuid(cardUuid);
    if (card != null) {
      await _gamificationEngine.onCardViewed(card);
    }
  }
}
