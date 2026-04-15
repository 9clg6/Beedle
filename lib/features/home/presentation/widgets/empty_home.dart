import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/widgets/calm_empty_state.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EmptyHome extends StatelessWidget {
  const EmptyHome({required this.onImport, super.key});
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return CalmEmptyState(
      digitalGlyph: '000',
      title: LocaleKeys.home_empty_title.tr(),
      body: LocaleKeys.home_empty_subtitle.tr(),
      cta: SquircleButton(
        label: LocaleKeys.home_empty_cta.tr(),
        icon: Icons.add_photo_alternate_rounded,
        onPressed: onImport,
      ),
    );
  }
}
