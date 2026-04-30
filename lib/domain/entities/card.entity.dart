import 'package:beedle/domain/enum/card_intent.enum.dart';
import 'package:beedle/domain/enum/card_level.enum.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.entity.freezed.dart';

/// Entité fiche — sortie principale de la digestion IA.
///
/// Contract de contenu (important) :
/// - [fullContent] est le **cœur** de la fiche : verbatim nettoyé par IA en
///   markdown (mêmes mots que la source, erreurs OCR corrigées, formatage
///   propre, blocs code préservés inline).
/// - [summary] est un TL;DR court (2-3 phrases) affiché EN HAUT de la fiche,
///   jamais en remplacement du contenu.
/// - [teaserHook] est généré à partir de [fullContent] (pas du résumé) —
///   il sert de payload pour le push-teaser.
///
/// Une Card agrège 1 à N screenshots (fusion FR-006), ses métadonnées
/// d'engagement et un embedding pour la recherche sémantique.
@freezed
abstract class CardEntity with _$CardEntity {
  const factory CardEntity({
    required String uuid,
    required String title,
    required String summary,
    required String fullContent,
    required CardLevel level,
    required List<String> tags,
    required String language,
    required String teaserHook,
    required IngestionStatus status,
    required DateTime createdAt,
    @Default(0) int viewedCount,
    @Default(<double>[]) List<double> embedding,
    @Default(CardIntent.read) CardIntent intent,
    @Default(false) bool intentOverridden,
    int? estimatedMinutes,
    String? sourceUrl,
    String? primaryAction,
    DateTime? viewedAt,
    DateTime? testedAt,
  }) = _CardEntity;
}

extension CardEntityX on CardEntity {
  bool get isGenerated => status == IngestionStatus.completed;
  bool get isPending =>
      status == IngestionStatus.queued || status == IngestionStatus.processing;
  bool get isFailed => status == IngestionStatus.failed;
  bool get isTested => testedAt != null;

  /// Éligible pour Daily Lesson : intent=apply + non testée + généré.
  bool get isDailyLessonEligible =>
      isGenerated && intent == CardIntent.apply && testedAt == null;

  /// Exclue des push notifications (cards `reference` ne dérangent jamais).
  bool get isPushEligible => intent != CardIntent.reference;

  Duration? get sinceViewed {
    final DateTime? v = viewedAt;
    if (v == null) return null;
    return DateTime.now().difference(v);
  }

  bool get isStale {
    final Duration? d = sinceViewed;
    return d == null || d.inDays > 14;
  }

  /// Une carte est « NEW » si elle vient d'être scannée et pas encore vue.
  ///
  /// Règle : jamais ouverte (`viewedAt == null` ET `viewedCount == 0`) ET
  /// créée dans les 48 dernières heures. La fenêtre de 48h évite d'afficher
  /// NEW sur de vieilles cartes oubliées (UX pollution sinon).
  bool get isNew {
    if (viewedAt != null || viewedCount > 0) return false;
    final Duration sinceCreated = DateTime.now().difference(createdAt);
    return sinceCreated.inHours < 48;
  }
}
