import 'package:objectbox/objectbox.dart';

/// Modèle local Card pour ObjectBox.
///
/// Contract : [fullContent] est le cœur (markdown nettoyé). [summary] sert
/// juste de header TL;DR. [teaserHook] est la ligne poussée en notif.
@Entity()
class CardLocalModel {
  CardLocalModel({
    required this.uuid,
    required this.title,
    required this.summary,
    required this.fullContent,
    required this.level,
    required this.tagsJson,
    required this.language,
    required this.teaserHook,
    required this.status,
    required this.createdAt,
    this.id = 0,
    this.embedding,
    this.viewedCount = 0,
    this.viewedAt,
    this.testedAt,
    this.estimatedMinutes,
    this.sourceUrl,
    this.intent = 'read',
    this.intentOverridden = false,
    this.primaryAction,
  });

  @Id()
  int id;

  @Index(type: IndexType.hash)
  @Unique()
  String uuid;

  String title;

  /// TL;DR court (2-3 phrases) affiché en header.
  String summary;

  /// Contenu markdown nettoyé — le vrai cœur de la fiche.
  String fullContent;

  String tagsJson;
  String level;
  String language;
  String teaserHook;
  String status;

  /// Intent (apply|read|reference). Default 'read' pour backward-compat.
  String intent;

  /// True si l'user a manuellement override l'intent — LLM ne re-classe pas
  /// lors d'un re-digest (fusion).
  bool intentOverridden;

  /// Action concrète extraite par le LLM (intent=apply uniquement).
  /// Null pour intent!=apply ou cards pré-feature.
  String? primaryAction;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  int viewedCount;

  @Property(type: PropertyType.date)
  DateTime? viewedAt;

  @Property(type: PropertyType.date)
  DateTime? testedAt;

  int? estimatedMinutes;
  String? sourceUrl;

  @HnswIndex(dimensions: 1536, distanceType: VectorDistanceType.cosine)
  @Property(type: PropertyType.floatVector)
  List<double>? embedding;
}
