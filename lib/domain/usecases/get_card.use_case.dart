import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/foundation/interfaces/future.usecases.dart';

final class GetCardUseCase
    extends FutureUseCaseWithParams<CardEntity?, String> {
  GetCardUseCase({required CardRepository cardRepository})
    : _cardRepository = cardRepository;

  final CardRepository _cardRepository;

  @override
  Future<CardEntity?> invoke(String uuid) => _cardRepository.getByUuid(uuid);
}
