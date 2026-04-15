import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/core/providers/usecase_providers.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/foundation/interfaces/results.usecases.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/glass_card.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:beedle/presentation/widgets/squircle_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

@RoutePage()
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPrefs =
        ref.watch(_prefsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.settings_title.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          onPressed: () => context.router.maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.neutral8),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: asyncPrefs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) =>
                Center(child: Text(LocaleKeys.common_error_generic.tr())),
            data: (prefs) {
              return ListView(
                padding: const EdgeInsets.all(CalmSpace.s6),
                children: <Widget>[
                  _Section(title: LocaleKeys.settings_sections_general.tr()),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    elevated: false,
                    child: _SwitchTile(
                      title: 'Auto-import (Android)',
                      value: prefs.autoImportEnabled,
                      onChanged: (v) async {
                        await ref
                            .read(userPreferencesRepositoryProvider)
                            .save(prefs.copyWith(autoImportEnabled: v));
                        ref.invalidate(_prefsProvider);
                      },
                    ),
                  ),
                  const Gap(CalmSpace.s7),
                  _Section(title: LocaleKeys.settings_sections_privacy.tr()),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    elevated: false,
                    child: _SwitchTile(
                      title: LocaleKeys.settings_analytics_consent.tr(),
                      value: prefs.analyticsConsent,
                      onChanged: (v) async {
                        await ref
                            .read(userPreferencesRepositoryProvider)
                            .save(prefs.copyWith(analyticsConsent: v));
                        await ref.read(analyticsServiceProvider).setConsent(v);
                        ref.invalidate(_prefsProvider);
                      },
                    ),
                  ),
                  const Gap(CalmSpace.s7),
                  const _Section(title: 'PIPELINE'),
                  SquircleButton(
                    label: 'Rejouer les imports échoués',
                    icon: Icons.refresh_rounded,
                    variant: SquircleButtonVariant.secondary,
                    expand: true,
                    onPressed: () async {
                      final count = await ref
                          .read(ingestionJobRepositoryProvider)
                          .retryFailed();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.ink,
                            content: Text(
                              count == 0
                                  ? 'Aucun job à rejouer.'
                                  : '$count job(s) remis en queue.',
                              style: const TextStyle(color: AppColors.canvas),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const Gap(CalmSpace.s7),
                  const _Section(title: 'DONNÉES'),
                  SquircleButton(
                    label: LocaleKeys.settings_export_data.tr(),
                    icon: Icons.download_rounded,
                    variant: SquircleButtonVariant.secondary,
                    expand: true,
                    onPressed: () async {
                      final ResultState<String> path = await ref
                          .read(exportAllDataUseCaseProvider)
                          .execute();
                      if (context.mounted && path.data != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Exported: ${path.data}')),
                        );
                      }
                    },
                  ),
                  const Gap(CalmSpace.s3),
                  SquircleButton(
                    label: LocaleKeys.settings_wipe_data.tr(),
                    icon: Icons.delete_outline_rounded,
                    variant: SquircleButtonVariant.destructive,
                    expand: true,
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.canvas,
                          content: Text(
                            LocaleKeys.settings_wipe_confirm.tr(),
                            style: Theme.of(ctx).textTheme.bodyLarge,
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(
                                LocaleKeys.common_action_cancel.tr(),
                                style: const TextStyle(
                                    color: AppColors.neutral7),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(
                                LocaleKeys.common_action_confirm.tr(),
                                style:
                                    const TextStyle(color: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm ?? false) {
                        await ref.read(wipeAllDataUseCaseProvider).execute();
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

final FutureProvider<UserPreferencesEntity> _prefsProvider =
    FutureProvider<UserPreferencesEntity>((ref) async {
  return ref.read(userPreferencesRepositoryProvider).load();
});

/// Section header — label.sm uppercase, +3% tracking.
class _Section extends StatelessWidget {
  const _Section({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s3,
        0,
        0,
        CalmSpace.s3,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.neutral6,
            ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s6,
        CalmSpace.s4,
        CalmSpace.s4,
        CalmSpace.s4,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.ink,
            activeTrackColor: AppColors.ink,
            inactiveThumbColor: AppColors.canvas,
            inactiveTrackColor: AppColors.neutral3,
          ),
        ],
      ),
    );
  }
}
