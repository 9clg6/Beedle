import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_day.entity.freezed.dart';

/// Un jour d'activité utilisateur — 1 entrée ObjectBox par jour civil.
///
/// Alimente l'activity graph GitHub-style + les calculs de streak.
@freezed
abstract class ActivityDayEntity with _$ActivityDayEntity {
  const factory ActivityDayEntity({
    required DateTime day,
    @Default(0) int cardsImported,
    @Default(0) int cardsViewed,
    @Default(0) int cardsTested,
  }) = _ActivityDayEntity;
}

extension ActivityDayEntityX on ActivityDayEntity {
  bool get isActive => cardsImported > 0 || cardsViewed > 0 || cardsTested > 0;

  /// Score d'intensité (0-4) pour color-coding activity graph.
  int get intensity {
    final total = cardsImported + cardsViewed * 2 + cardsTested * 3;
    if (total == 0) return 0;
    if (total <= 3) return 1;
    if (total <= 8) return 2;
    if (total <= 15) return 3;
    return 4;
  }
}
