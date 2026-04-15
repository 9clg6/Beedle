import 'package:beedle/domain/entities/card.entity.dart';

abstract interface class CardRepository {
  Future<List<CardEntity>> getAll({int? limit, int? offset});

  Future<CardEntity?> getByUuid(String uuid);

  Future<CardEntity> upsert(CardEntity card);

  Future<void> delete(String uuid);

  /// Recherche sémantique par embedding.
  /// [queryEmbedding] est le vecteur dim=1536 calculé depuis la query user.
  Future<List<CardEntity>> semanticSearch({
    required List<double> queryEmbedding,
    int limit = 10,
    bool restrictToCurrentMonth = false,
  });

  /// Retourne la Card candidate pour la "suggestion du jour".
  Future<CardEntity?> pickTodayCard({List<String>? preferredTags});

  /// Retourne les Cards "à revoir" (viewedAt > 14 jours OU null).
  Future<List<CardEntity>> getStaleCards({int limit = 3});

  /// Marque une Card comme vue (incrémente viewedCount + met à jour viewedAt).
  Future<void> markViewed(String uuid);

  /// Marque une Card comme testée.
  Future<void> markTested(String uuid);

  /// Stream reactif sur les changements de la collection.
  Stream<List<CardEntity>> watchAll();

  /// Compte total de Cards.
  Future<int> count();
}
