import 'package:objectbox/objectbox.dart';

@Entity()
class NotificationRecordLocalModel {
  NotificationRecordLocalModel({
    required this.uuid,
    required this.type,
    required this.scheduledAt,
    this.id = 0,
    this.cardUuid,
    this.content,
    this.sentAt,
    this.tappedAt,
    this.dismissedAt,
  });

  @Id()
  int id;

  @Index(type: IndexType.hash)
  @Unique()
  String uuid;

  @Index()
  String type;

  @Property(type: PropertyType.date)
  DateTime scheduledAt;

  String? cardUuid;
  String? content;

  @Property(type: PropertyType.date)
  DateTime? sentAt;

  @Property(type: PropertyType.date)
  DateTime? tappedAt;

  @Property(type: PropertyType.date)
  DateTime? dismissedAt;
}
