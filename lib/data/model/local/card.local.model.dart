import 'package:objectbox/objectbox.dart';

/// Modèle local Card pour ObjectBox.
///
/// Contract : [fullContent] est le cœur (markdown nettoyé). [summary] sert
/// juste de header TL;DR. [teaserHook] est la ligne poussée en notif.
@Entity()
class CardLocalModel {
  CardLocalModel({
    required this.uuid, required this.title, required this.summary, required this.fullContent, required this.level, required this.tagsJson, required this.language, required this.teaserHook, required this.status, required this.createdAt, this.id = 0,
    this.embedding,
    this.viewedCount = 0,
    this.viewedAt,
    this.testedAt,
    this.estimatedMinutes,
    this.sourceUrl,
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
