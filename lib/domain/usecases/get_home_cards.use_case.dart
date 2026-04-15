import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/foundation/interfaces/future.usecases.dart';

/// Vue home : suggestion du jour + "à revoir".
class HomeCardsResult {
  const HomeCardsResult({
    required this.suggestion,
    required this.rewatch,
    required this.totalCards,
  });

  final CardEntity? suggestion;
  final List<CardEntity> rewatch;
  final int totalCards;
}

final class GetHomeCardsUseCase extends FutureUseCase<HomeCardsResult> {
  GetHomeCardsUseCase({required CardRepository cardRepository})
      : _cardRepository = cardRepository;

  final CardRepository _cardRepository;

  @override
  Future<HomeCardsResult> invoke() async {
    final total = await _cardRepository.count();
    var today = await _cardRepository.pickTodayCard();

    // Récupère TOUTES les cards, récent en premier (l'ordre par défaut de
    // `getAll` est descending sur createdAt — voir data source impl).
    final all = await _cardRepository.getAll();

    // Fallback : si pas de suggestion mais des cards existent, on prend la
    // plus récente.
    today ??= all.isNotEmpty ? all.first : null;

    // "rewatch" devient la liste complète moins la suggestion — la Home
    // affiche tout pour que l'user puisse parcourir.
    final todaySnapshot = today;
    final rewatch = todaySnapshot == null
        ? all
        : all.where((c) => c.uuid != todaySnapshot.uuid).toList();

    return HomeCardsResult(
      suggestion: today,
      rewatch: rewatch,
      totalCards: total,
    );
  }
}
