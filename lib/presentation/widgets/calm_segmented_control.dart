import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:flutter/material.dart';

/// CalmSurface segmented control — pill noire "active" sur track glass.soft.
///
/// Animation légère, 1 segment actif à la fois, zéro shadow.
class CalmSegmentedControl<T> extends StatelessWidget {
  const CalmSegmentedControl({
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    assert(values.length == labels.length, 'values & labels mismatch');
    final TextStyle? baseStyle = Theme.of(context).textTheme.labelMedium;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.neutral2,
        borderRadius: BorderRadius.circular(CalmRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < values.length; i++)
            _Segment<T>(
              label: labels[i],
              isActive: values[i] == selected,
              onTap: () => onChanged(values[i]),
              baseStyle: baseStyle,
            ),
        ],
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.baseStyle,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final TextStyle? baseStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: CalmDuration.quick,
          curve: CalmCurves.standard,
          padding: const EdgeInsets.symmetric(
            horizontal: CalmSpace.s4,
            vertical: CalmSpace.s2,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(CalmRadius.pill),
          ),
          child: Text(
            label,
            style: baseStyle?.copyWith(
              color: isActive ? AppColors.canvas : AppColors.neutral7,
            ),
          ),
        ),
      ),
    );
  }
}
