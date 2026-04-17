import 'package:objectbox/objectbox.dart';

/// Modèle local ObjectBox pour `EngagementMessageEntity`.
///
/// Un message est lié à une card via [cardUuid] (pas de relation
/// ObjectBox native — on reste simple, lookup côté repo).
@Entity()
class EngagementMessageLocalModel {
  EngagementMessageLocalModel({
    required this.uuid,
    required this.cardUuid,
    required this.content,
    required this.type,
    required this.format,
    required this.delayDays,
    required this.createdAt,
    this.id = 0,
    this.scheduledAt,
    this.shownAt,
  });

  @Id()
  int id;

  @Index(type: IndexType.hash)
  @Unique()
  String uuid;

  @Index()
  String cardUuid;

  String content;
  String type;
  String format;
  int delayDays;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime? scheduledAt;

  @Property(type: PropertyType.date)
  DateTime? shownAt;
}
