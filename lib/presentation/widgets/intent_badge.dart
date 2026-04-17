import 'package:beedle/domain/enum/card_intent.enum.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Badge discret pour l'intent d'une card — Lucide-like icon + label optionnel.
///
/// Variantes :
/// - `apply`     → PlayCircle ember
/// - `read`      → BookOpen neutral.7
/// - `reference` → FileText neutral.5
class IntentBadge extends StatelessWidget {
  const IntentBadge({
    required this.intent,
    this.compact = false,
    this.onTap,
    super.key,
  });

  /// Intent à afficher.
  final CardIntent intent;

  /// [compact] `true` → juste l'icône (16px). `false` → icône + label.
  final bool compact;

  /// Optionnel — active le tap (pour le override sheet).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final _IntentSpec spec = _specFor(intent);

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(spec.icon, size: 14, color: spec.color),
        if (!compact) ...<Widget>[
          const SizedBox(width: CalmSpace.s2),
          Text(
            spec.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: spec.color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ],
    );

    final Widget container = Container(
      padding: compact
          ? const EdgeInsets.all(4)
          : const EdgeInsets.symmetric(
              horizontal: CalmSpace.s3,
              vertical: 4,
            ),
      decoration: BoxDecoration(
        color: spec.background,
        borderRadius: BorderRadius.circular(CalmRadius.pill),
      ),
      child: content,
    );

    if (onTap == null) return container;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CalmRadius.pill),
      child: container,
    );
  }

  static _IntentSpec _specFor(CardIntent intent) {
    switch (intent) {
      case CardIntent.apply:
        return _IntentSpec(
          icon: Icons.play_circle_outline_rounded,
          color: AppColors.ember,
          background: const Color(0x0AFF6B2E), // 4% ember
          label: LocaleKeys.intent_apply.tr(),
        );
      case CardIntent.read:
        return _IntentSpec(
          icon: Icons.menu_book_outlined,
          color: AppColors.neutral7,
          background: AppColors.neutral2,
          label: LocaleKeys.intent_read.tr(),
        );
      case CardIntent.reference:
        return _IntentSpec(
          icon: Icons.description_outlined,
          color: AppColors.neutral5,
          background: AppColors.neutral2,
          label: LocaleKeys.intent_reference.tr(),
        );
    }
  }
}

class _IntentSpec {
  const _IntentSpec({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final Color background;
  final String label;
}

/// Ouvre un bottom sheet qui permet à l'user de changer l'intent.
/// Retourne le nouvel intent si choisi, null si dismiss.
Future<CardIntent?> showIntentOverrideSheet(
  BuildContext context, {
  required CardIntent current,
}) async {
  return showModalBottomSheet<CardIntent>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return _IntentOverrideSheet(current: current);
    },
  );
}

class _IntentOverrideSheet extends StatelessWidget {
  const _IntentOverrideSheet({required this.current});
  final CardIntent current;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(CalmRadius.xl3),
      ),
      child: ColoredBox(
        color: AppColors.canvas,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              CalmSpace.s6,
              CalmSpace.s6,
              CalmSpace.s6,
              CalmSpace.s7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  LocaleKeys.intent_sheet_title.tr(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: CalmSpace.s5),
                for (final CardIntent intent in CardIntent.values) ...<Widget>[
                  _IntentRow(
                    intent: intent,
                    selected: intent == current,
                    onTap: () => Navigator.of(context).pop(intent),
                  ),
                  if (intent != CardIntent.values.last)
                    const SizedBox(height: CalmSpace.s3),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntentRow extends StatelessWidget {
  const _IntentRow({
    required this.intent,
    required this.selected,
    required this.onTap,
  });
  final CardIntent intent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final _IntentSpec spec = IntentBadge._specFor(intent);
    final String description = _descriptionFor(intent);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CalmRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(CalmSpace.s5),
        decoration: BoxDecoration(
          color: selected ? spec.background : Colors.transparent,
          borderRadius: BorderRadius.circular(CalmRadius.xl),
          border: Border.all(
            color: selected ? spec.color : AppColors.neutral3,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(spec.icon, size: 22, color: spec.color),
            const SizedBox(width: CalmSpace.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    spec.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: spec.color,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.neutral7,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_rounded,
                size: 20,
                color: spec.color,
              ),
          ],
        ),
      ),
    );
  }

  static String _descriptionFor(CardIntent intent) {
    switch (intent) {
      case CardIntent.apply:
        return LocaleKeys.intent_apply_description.tr();
      case CardIntent.read:
        return LocaleKeys.intent_read_description.tr();
      case CardIntent.reference:
        return LocaleKeys.intent_reference_description.tr();
    }
  }
}
