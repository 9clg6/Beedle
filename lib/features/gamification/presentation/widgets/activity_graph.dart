import 'package:beedle/domain/entities/activity_day.entity.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Activity graph GitHub-style : 12 semaines × 7 jours, color par intensité.
class ActivityGraph extends StatelessWidget {
  const ActivityGraph({required this.days, super.key});

  final List<ActivityDayEntity> days;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Bucket par jour (ms midnight).
    final Map<int, ActivityDayEntity> byDay = <int, ActivityDayEntity>{
      for (final ActivityDayEntity d in days) _dayKey(d.day): d,
    };

    final DateTime today = _todayMidnight();
    // 12 semaines = 84 jours. Dernier jour = aujourd'hui.
    const int totalWeeks = 12;
    final List<List<Color>> grid = List<List<Color>>.generate(totalWeeks, (
      int w,
    ) {
      return List<Color>.generate(7, (int d) {
        final int daysAgo = (totalWeeks - 1 - w) * 7 + (6 - d);
        final DateTime day = today.subtract(Duration(days: daysAgo));
        final ActivityDayEntity? entry = byDay[_dayKey(day)];
        final int intensity = entry?.intensity ?? 0;
        return _intensityColor(intensity, colorScheme);
      });
    });

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cellSize =
            (constraints.maxWidth - (totalWeeks - 1) * 4) / totalWeeks;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int w = 0; w < totalWeeks; w++) ...<Widget>[
                  Column(
                    children: <Widget>[
                      for (int d = 0; d < 7; d++) ...<Widget>[
                        Container(
                          width: cellSize,
                          height: cellSize,
                          decoration: BoxDecoration(
                            color: grid[w][d],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        if (d < 6) const Gap(3),
                      ],
                    ],
                  ),
                  if (w < totalWeeks - 1) const Gap(4),
                ],
              ],
            ),
            const Gap(10),
            Row(
              children: <Widget>[
                Text('Moins', style: Theme.of(context).textTheme.labelSmall),
                const Gap(6),
                for (int i = 0; i <= 4; i++) ...<Widget>[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _intensityColor(i, colorScheme),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(3),
                ],
                const Gap(4),
                Text('Plus', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        );
      },
    );
  }

  Color _intensityColor(int intensity, ColorScheme cs) {
    switch (intensity) {
      case 0:
        return cs.outline.withValues(alpha: 0.3);
      case 1:
        return AppColors.orange500.withValues(alpha: 0.3);
      case 2:
        return AppColors.orange500.withValues(alpha: 0.5);
      case 3:
        return AppColors.orange500.withValues(alpha: 0.75);
      default:
        return AppColors.orange500;
    }
  }

  int _dayKey(DateTime d) =>
      DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;

  DateTime _todayMidnight() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
