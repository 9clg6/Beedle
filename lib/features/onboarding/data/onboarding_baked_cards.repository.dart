import 'dart:convert';

import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/enum/card_intent.enum.dart';
import 'package:beedle/domain/enum/card_level.enum.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/domain/repositories/embeddings.repository.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

/// Charge les "fiches d'onboarding" pré-baked depuis les assets et les
/// persiste en vraies `CardEntity` au moment où l'utilisateur termine
/// l'onboarding — ainsi quand il atteint la Home, sa bibliothèque
/// contient déjà les 3 fiches qu'il a vues défiler dans l'écran 14.
///
/// Pourquoi pas runtime LLM ? Latence variable, output non-déterministe,
/// coûts répétés à chaque install. Le bake une fois, ship pour toujours.
class OnboardingBakedCardsRepository {
  OnboardingBakedCardsRepository({
    required CardRepository cardRepository,
    required EmbeddingsRepository embeddingsRepository,
    Uuid? uuid,
  }) : _cardRepository = cardRepository,
       _embeddingsRepository = embeddingsRepository,
       _uuid = uuid ?? const Uuid();

  final CardRepository _cardRepository;
  final EmbeddingsRepository _embeddingsRepository;
  final Uuid _uuid;
  final Log _log = Log.named('OnboardingBakedCards');

  /// Slugs des 3 fiches packagées dans `assets/onboarding/baked/cards/`.
  static const List<String> _kCardSlugs = <String>[
    'card-01',
    'card-02',
    'card-03',
  ];

  static const String _kAssetPrefix = 'assets/onboarding/baked/cards/';

  /// Charge les 3 fiches baked depuis les assets et retourne leur
  /// version "preview" (pas encore persistée) — utilisée par l'écran 14
  /// pour afficher la grid visuelle avant de les persister.
  Future<List<CardEntity>> loadPreview() async {
    final List<CardEntity> cards = <CardEntity>[];
    for (final String slug in _kCardSlugs) {
      try {
        final CardEntity card = await _loadOne(slug, withEmbedding: false);
        cards.add(card);
      } on Exception catch (e) {
        _log.warn('Failed to load baked card $slug: $e');
      }
    }
    return cards;
  }

  /// Persiste les 3 fiches baked SANS calculer leur embedding (call
  /// synchrone, zéro network). Utilisé au moment où l'utilisateur
  /// atteint l'écran 14 pour que le tap sur une card ouvre le détail
  /// immédiatement (l'embedding est rattrappé plus tard via [persistAll]
  /// au `finishOnboarding()`, upsert idempotent grâce aux UUID v5).
  Future<List<CardEntity>> persistPreview() async {
    final List<CardEntity> persisted = <CardEntity>[];
    for (final String slug in _kCardSlugs) {
      try {
        final CardEntity card = await _loadOne(slug, withEmbedding: false);
        await _cardRepository.upsert(card);
        persisted.add(card);
      } on Exception catch (e) {
        _log.warn('Failed to persist preview card $slug: $e');
      }
    }
    return persisted;
  }

  /// Persiste les 3 fiches baked dans le `cardRepository` (avec embedding
  /// calculé depuis le worker). Idempotent — si l'utilisateur relance
  /// l'onboarding, les fiches sont upsertées (mêmes uuid déterministes).
  Future<int> persistAll() async {
    int persisted = 0;
    for (final String slug in _kCardSlugs) {
      try {
        final CardEntity card = await _loadOne(slug, withEmbedding: true);
        await _cardRepository.upsert(card);
        persisted++;
      } on Exception catch (e) {
        // Ne pas bloquer l'onboarding si une fiche échoue (network, etc.)
        // — l'utilisateur arrivera sur Home avec moins de 3 fiches mais
        // pas de crash. Idempotent au prochain run.
        _log.warn('Failed to persist baked card $slug: $e');
      }
    }
    _log.info('Persisted $persisted/${_kCardSlugs.length} baked cards.');
    return persisted;
  }

  Future<CardEntity> _loadOne(
    String slug, {
    required bool withEmbedding,
  }) async {
    final String raw = await rootBundle.loadString('$_kAssetPrefix$slug.json');
    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;

    final String fullContent = json['fullContent'] as String;
    final List<double> embedding = withEmbedding
        ? await _embeddingsRepository.embed(fullContent)
        : const <double>[];

    // UUID déterministe par slug → upsert idempotent. v5 sur un
    // namespace fixe + le slug ; aucune lib supplémentaire requise.
    const String namespace = '0ea6c3e0-7ec0-11ee-b962-0242ac120002';
    final String deterministicUuid = _uuid.v5(namespace, slug);

    return CardEntity(
      uuid: deterministicUuid,
      title: json['title'] as String,
      summary: json['summary'] as String,
      fullContent: fullContent,
      level: _parseLevel(json['level'] as String),
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      language: json['language'] as String,
      teaserHook: json['teaserHook'] as String,
      status: IngestionStatus.completed,
      createdAt: DateTime.now(),
      embedding: embedding,
      intent: _parseIntent(json['intent'] as String),
    );
  }

  static CardLevel _parseLevel(String raw) {
    return switch (raw) {
      'beginner' => CardLevel.beginner,
      'intermediate' => CardLevel.intermediate,
      'advanced' => CardLevel.advanced,
      _ => CardLevel.beginner,
    };
  }

  static CardIntent _parseIntent(String raw) {
    return switch (raw) {
      'apply' => CardIntent.apply,
      'read' => CardIntent.read,
      'reference' => CardIntent.reference,
      _ => CardIntent.read,
    };
  }
}
