import 'package:objectbox/objectbox.dart';

@Entity()
class ActivityDayLocalModel {
  ActivityDayLocalModel({
    required this.dayEpoch, this.id = 0,
    this.cardsImported = 0,
    this.cardsViewed = 0,
    this.cardsTested = 0,
  });

  @Id()
  int id;

  /// Date en ms UTC à minuit (clé logique d'unicité).
  @Index(type: IndexType.value)
  @Unique()
  @Property(type: PropertyType.date)
  DateTime dayEpoch;

  int cardsImported;
  int cardsViewed;
  int cardsTested;
}
