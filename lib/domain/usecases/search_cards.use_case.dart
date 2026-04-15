import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/params/search_cards.param.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/domain/repositories/embeddings.repository.dart';
import 'package:beedle/foundation/interfaces/future.usecases.dart';

/// Recherche sémantique de fiches par query texte.
///
/// 1. Calcule l'embedding de la query via EmbeddingsRepository.
/// 2. Lance une recherche HNSW sur ObjectBox via CardRepository.
final class SearchCardsUseCase extends FutureUseCaseWithParams<List<CardEntity>, SearchCardsParam> {
  SearchCardsUseCase({
    required CardRepository cardRepository,
    required EmbeddingsRepository embeddingsRepository,
  })  : _cardRepository = cardRepository,
        _embeddingsRepository = embeddingsRepository;

  final CardRepository _cardRepository;
  final EmbeddingsRepository _embeddingsRepository;

  @override
  Future<List<CardEntity>> invoke(SearchCardsParam params) async {
    final query = params.query.trim();
    if (query.isEmpty) return <CardEntity>[];

    // 1. Sémantique via embeddings (échoue silencieusement si Worker/embeddings down).
    List<CardEntity> semantic = <CardEntity>[];
    try {
      final queryEmbedding = await _embeddingsRepository.embed(query);
      semantic = await _cardRepository.semanticSearch(
        queryEmbedding: queryEmbedding,
        limit: params.limit,
        restrictToCurrentMonth: params.restrictToCurrentMonth,
      );
    } on Exception catch (_) {
      // fallback keyword seulement
    }

    // 2. Keyword fallback — tourne TOUJOURS, dédoublonne avec semantic.
    //    Case-insensitive sur title + summary + fullContent + tags.
    final all = await _cardRepository.getAll();
    final q = query.toLowerCase();
    final keyword = all.where((c) {
      final haystack = <String>[
        c.title,
        c.summary,
        c.fullContent,
        c.tags.join(' '),
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();

    // Merge : semantic d'abord (pertinence), puis keyword pour combler.
    final seen = <String>{};
    final merged = <CardEntity>[];
    for (final c in <CardEntity>[...semantic, ...keyword]) {
      if (seen.add(c.uuid)) merged.add(c);
      if (merged.length >= params.limit) break;
    }
    return merged;
  }
}
