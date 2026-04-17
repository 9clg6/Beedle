import 'package:objectbox/objectbox.dart';

@Entity()
class IngestionJobLocalModel {
  IngestionJobLocalModel({
    required this.uuid,
    required this.screenshotUuidsJson,
    required this.status,
    required this.createdAt,
    this.id = 0,
    this.attempts = 0,
    this.lastError,
    this.cardUuid,
    this.completedAt,
  });

  @Id()
  int id;

  @Index(type: IndexType.hash)
  @Unique()
  String uuid;

  /// JSON array des UUIDs de screenshots.
  String screenshotUuidsJson;

  @Index()
  String status;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  int attempts;
  String? lastError;
  String? cardUuid;

  @Property(type: PropertyType.date)
  DateTime? completedAt;
}
