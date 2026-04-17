import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/foundation/interfaces/future.usecases.dart';

final class DeleteCardUseCase extends FutureUseCaseWithParams<void, String> {
  DeleteCardUseCase({required CardRepository cardRepository})
    : _cardRepository = cardRepository;

  final CardRepository _cardRepository;

  @override
  Future<void> invoke(String cardUuid) => _cardRepository.delete(cardUuid);
}
