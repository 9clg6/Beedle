import 'package:objectbox/objectbox.dart';

@Entity()
class WeeklyChallengeLocalModel {
  WeeklyChallengeLocalModel({
    required this.weekStart, required this.type, required this.target, this.id = 0,
    this.progress = 0,
    this.completedAt,
  });

  @Id()
  int id;

  @Index()
  @Unique()
  @Property(type: PropertyType.date)
  DateTime weekStart;

  String type;
  int target;
  int progress;

  @Property(type: PropertyType.date)
  DateTime? completedAt;
}
