import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/auth.provider.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/core/providers/usecase_providers.dart';
import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/features/home/presentation/providers/upload_display_state.provider.dart';
import 'package:beedle/features/home/presentation/screens/engagement_home.view_model.dart';
import 'package:beedle/features/home/presentation/screens/home.view_model.dart';
import 'package:beedle/foundation/interfaces/results.usecases.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/calm_back_button.dart';
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
    final AsyncValue<UserPreferencesEntity> asyncPrefs = ref.watch(
      _prefsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.settings_title.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leadingWidth: 60,
        leading: const CalmBackButton(),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: asyncPrefs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object e, StackTrace st) =>
                Center(child: Text(LocaleKeys.common_error_generic.tr())),
            data: (UserPreferencesEntity prefs) {
              final AuthUserEntity? user = ref.watch(currentUserProvider);
              return ListView(
                padding: const EdgeInsets.all(CalmSpace.s6),
                children: <Widget>[
                  _Section(title: LocaleKeys.auth_settings_section.tr()),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    elevated: false,
                    child: _AccountTile(user: user),
                  ),
                  const Gap(CalmSpace.s7),
                  _Section(title: LocaleKeys.settings_sections_general.tr()),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    elevated: false,
                    child: _SwitchTile(
                      title: LocaleKeys.settings_auto_import.tr(),
                      value: prefs.autoImportEnabled,
                      onChanged: (bool v) async {
                        await ref
                            .read(userPreferencesRepositoryProvider)
                            .save(prefs.copyWith(autoImportEnabled: v));
                        ref.invalidate(_prefsProvider);
                      },
                    ),
                  ),
                  const Gap(CalmSpace.s7),
                  _Section(title: LocaleKeys.settings_sections_voice.tr()),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    elevated: false,
                    child: Column(
                      children: <Widget>[
                        _SwitchTile(
                          title: LocaleKeys.settings_voice_terminal.tr(),
                          value: prefs.voiceTerminalEnabled,
                          onChanged: (bool v) async {
                            await ref
                                .read(userPreferencesRepositoryProvider)
                                .save(prefs.copyWith(voiceTerminalEnabled: v));
                            ref.invalidate(_prefsProvider);
                          },
                        ),
                        const _Divider(),
                        _SwitchTile(
                          title: LocaleKeys.settings_voice_push.tr(),
                          value: prefs.voicePushEnabled,
                          onChanged: (bool v) async {
                            await ref
                                .read(userPreferencesRepositoryProvider)
                                .save(prefs.copyWith(voicePushEnabled: v));
                            ref.invalidate(_prefsProvider);
                          },
                        ),
                        const _Divider(),
                        _QuotaSliderTile(
                          title: LocaleKeys.settings_voice_quota.tr(),
                          value: prefs.voicePushQuotaPerDay.clamp(0, 3),
                          onChanged: (int v) async {
                            await ref
                                .read(userPreferencesRepositoryProvider)
                                .save(prefs.copyWith(voicePushQuotaPerDay: v));
                            ref.invalidate(_prefsProvider);
                          },
                        ),
                        const _Divider(),
                        _SwitchTile(
                          title: LocaleKeys.settings_voice_zen.tr(),
                          value: prefs.voiceZenMode,
                          onChanged: (bool v) async {
                            await ref
                                .read(userPreferencesRepositoryProvider)
                                .save(prefs.copyWith(voiceZenMode: v));
                            ref.invalidate(_prefsProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                  const Gap(CalmSpace.s7),
                  _Section(
                    title: LocaleKeys.settings_sections_daily_lesson.tr(),
                  ),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    elevated: false,
                    child: Column(
                      children: <Widget>[
                        _SwitchTile(
                          title: LocaleKeys.settings_daily_lesson_push.tr(),
                          value: prefs.dailyLessonPushEnabled,
                          onChanged: (bool v) async {
                            final updated = prefs.copyWith(
                              dailyLessonPushEnabled: v,
                            );
                            await ref
                                .read(userPreferencesRepositoryProvider)
                                .save(updated);
                            await _rescheduleLesson(ref, updated);
                            ref.invalidate(_prefsProvider);
                          },
                        ),
                        const _Divider(),
                        _HourPickerTile(
                          title: LocaleKeys.settings_daily_lesson_hour.tr(),
                          value: prefs.dailyLessonHour,
                          onChanged: (int v) async {
                            final updated = prefs.copyWith(dailyLessonHour: v);
                            await ref
                                .read(userPreferencesRepositoryProvider)
                                .save(updated);
                            await _rescheduleLesson(ref, updated);
                            ref.invalidate(_prefsProvider);
                          },
                        ),
                      ],
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
                      onChanged: (bool v) async {
                        await ref
                            .read(userPreferencesRepositoryProvider)
                            .save(prefs.copyWith(analyticsConsent: v));
                        await ref.read(analyticsServiceProvider).setConsent(v);
                        ref.invalidate(_prefsProvider);
                      },
                    ),
                  ),
                  const Gap(CalmSpace.s7),
                  _Section(title: LocaleKeys.settings_sections_pipeline.tr()),
                  SquircleButton(
                    label: LocaleKeys.settings_replay_failed.tr(),
                    icon: Icons.refresh_rounded,
                    variant: SquircleButtonVariant.secondary,
                    expand: true,
                    onPressed: () async {
                      final int count = await ref
                          .read(ingestionJobRepositoryProvider)
                          .retryFailed();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.ink,
                            content: Text(
                              count == 0
                                  ? LocaleKeys.settings_replay_none.tr()
                                  : LocaleKeys.settings_replay_done.tr(
                                      namedArgs: <String, String>{
                                        'count': '$count',
                                      },
                                    ),
                              style: const TextStyle(color: AppColors.canvas),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const Gap(CalmSpace.s7),
                  _Section(title: LocaleKeys.settings_sections_data.tr()),
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
                          SnackBar(
                            content: Text(
                              LocaleKeys.settings_exported.tr(
                                namedArgs: <String, String>{
                                  'path': '${path.data}',
                                },
                              ),
                            ),
                          ),
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
                      final bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext ctx) => AlertDialog(
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
                                  color: AppColors.neutral7,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(
                                LocaleKeys.common_action_confirm.tr(),
                                style: const TextStyle(color: AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      );
                      if ((confirm ?? false) && context.mounted) {
                        await _performWipe(context, ref);
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
    FutureProvider<UserPreferencesEntity>((Ref ref) async {
      return ref.read(userPreferencesRepositoryProvider).load();
    });

/// Exécute le wipe complet + réinitialise les providers en cache + redirige
/// vers le splash qui relancera le flow (Onboarding si `onboardingCompletedAt`
/// est null, comme ça devient le cas après wipe).
///
/// Avant cette implémentation, `wipeAllDataUseCaseProvider.execute()` était
/// appelé isolément : la DB était bien vidée mais les providers Riverpod
/// gardaient leur cache en mémoire → Home, Dashboard, TerminalCard continuaient
/// à afficher les anciennes données jusqu'à un restart manuel de l'app.
Future<void> _performWipe(BuildContext context, WidgetRef ref) async {
  // 1. Wipe effectif (DB ObjectBox + analytics reset via DataManagementService).
  await ref.read(wipeAllDataUseCaseProvider).execute();

  // 2. Invalider les providers qui cachent des données dérivées de la DB.
  //    Le SplashRoute se chargera de disposer le reste via replaceAll, mais
  //    les providers globaux (home, engagement, upload progress) doivent être
  //    explicitement invalidés car ils peuvent rester en mémoire si encore
  //    référencés par d'autres listeners.
  ref
    ..invalidate(homeViewModelProvider)
    ..invalidate(engagementHomeViewModelProvider)
    ..invalidate(uploadDisplayStateProvider)
    ..invalidate(dismissedFailedJobsProvider)
    ..invalidate(_prefsProvider);

  if (!context.mounted) return;

  // 3. Feedback utilisateur — SnackBar discret, cohérent avec l'ancien
  //    pattern de la home (SnackBar floating ink).
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(
      backgroundColor: AppColors.ink,
      behavior: SnackBarBehavior.floating,
      shape: const StadiumBorder(),
      margin: const EdgeInsets.all(CalmSpace.s5),
      duration: const Duration(seconds: 3),
      content: Text(
        LocaleKeys.settings_wipe_done.tr(),
        style: const TextStyle(color: AppColors.canvas),
      ),
    ),
  );

  // 4. Relance le flow racine via Splash — qui décide (via
  //    `prefs.hasCompletedOnboarding` désormais à false) de router vers
  //    l'onboarding. Plus propre qu'un `pop()` qui laisserait l'user sur
  //    une home vide avec des caches potentiellement stale.
  await context.router.replaceAll(<PageRouteInfo<dynamic>>[
    const SplashRoute(),
  ]);
}

/// Re-planifie la Daily Lesson + teasers quand les prefs Voice/Lesson
/// changent. Best-effort : on ne bloque pas l'UX sur un échec.
Future<void> _rescheduleLesson(
  WidgetRef ref,
  UserPreferencesEntity prefs,
) async {
  try {
    final SubscriptionSnapshotEntity sub = await ref
        .read(subscriptionRepositoryProvider)
        .load();
    final scheduler = ref.read(notificationSchedulerServiceProvider);
    await scheduler.scheduleDailyLesson(prefs: prefs);
    await scheduler.scheduleTeasersForToday(
      prefs: prefs,
      subscription: sub,
    );
  } on Exception catch (_) {
    // silent — prefs sont sauvegardées, la replanif au prochain boot.
  }
}

/// Tile "Compte" — affiche l'email signed-in + bouton signout, ou bouton
/// signin si anonyme.
class _AccountTile extends ConsumerWidget {
  const _AccountTile({required this.user});

  final AuthUserEntity? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AuthUserEntity? user = this.user;

    if (user == null) {
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
                LocaleKeys.auth_settings_signed_in_anonymous.tr(),
                style: textTheme.bodyLarge,
              ),
            ),
            TextButton(
              onPressed: () => context.router.push(AuthRoute(required: true)),
              child: Text(
                LocaleKeys.auth_settings_signin.tr(),
                style: textTheme.labelLarge?.copyWith(color: AppColors.ink),
              ),
            ),
          ],
        ),
      );
    }

    final String? email = user.email;
    final String label = email == null
        ? LocaleKeys.auth_settings_signed_in_anonymous.tr()
        : LocaleKeys.auth_settings_signed_in_as.tr(
            namedArgs: <String, String>{'email': email},
          );

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
              label,
              style: textTheme.bodyLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => _signOut(ref),
            child: Text(
              LocaleKeys.auth_settings_signout.tr(),
              style: textTheme.labelLarge?.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(WidgetRef ref) async {
    // Le service track lui-même `authSignout` — ne pas dupliquer ici.
    await ref.read(authServiceProvider).signOut();
  }
}

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

class _QuotaSliderTile extends StatelessWidget {
  const _QuotaSliderTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s6,
        CalmSpace.s4,
        CalmSpace.s6,
        CalmSpace.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                LocaleKeys.settings_voice_quota_value.tr(
                  namedArgs: <String, String>{'count': '$value'},
                ),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral6,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.ink,
              inactiveTrackColor: AppColors.neutral3,
              thumbColor: AppColors.ink,
              overlayColor: AppColors.ink.withValues(alpha: 0.08),
              trackHeight: 2,
            ),
            child: Slider(
              value: value.toDouble(),
              max: 3,
              divisions: 3,
              onChanged: (double v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: CalmSpace.s5),
      child: Divider(height: 1, color: AppColors.neutral2),
    );
  }
}

class _HourPickerTile extends StatelessWidget {
  const _HourPickerTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CalmSpace.s6,
        CalmSpace.s4,
        CalmSpace.s6,
        CalmSpace.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                LocaleKeys.settings_daily_lesson_hour_value.tr(
                  namedArgs: <String, String>{
                    'hour': value.toString().padLeft(2, '0'),
                  },
                ),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral6,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.ink,
              inactiveTrackColor: AppColors.neutral3,
              thumbColor: AppColors.ink,
              overlayColor: AppColors.ink.withValues(alpha: 0.08),
              trackHeight: 2,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 6,
              max: 22,
              divisions: 16,
              onChanged: (double v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}
