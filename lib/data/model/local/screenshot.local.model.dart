import 'package:objectbox/objectbox.dart';

@Entity()
class ScreenshotLocalModel {
  ScreenshotLocalModel({
    required this.uuid,
    required this.filePath,
    required this.sha256,
    required this.capturedAt,
    this.id = 0,
    this.ocrText = '',
    this.ocrConfidence = 0.0,
    this.cardUuid,
    this.detectedLanguage,
  });

  @Id()
  int id;

  @Index(type: IndexType.hash)
  @Unique()
  String uuid;

  @Index(type: IndexType.hash)
  @Unique()
  String sha256;

  String filePath;

  @Property(type: PropertyType.date)
  DateTime capturedAt;

  String ocrText;
  double ocrConfidence;

  @Index(type: IndexType.hash)
  String? cardUuid;

  String? detectedLanguage;
}
