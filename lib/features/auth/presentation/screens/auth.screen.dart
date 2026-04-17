import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/features/auth/presentation/screens/auth.state.dart';
import 'package:beedle/features/auth/presentation/screens/auth.view_model.dart';
import 'package:beedle/features/auth/presentation/widgets/auth_provider_button.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/theme/calm_tokens.dart';
import 'package:beedle/presentation/widgets/beedle_icon_asset.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Écran d'authentification — premier écran après le splash pour les nouveaux
/// utilisateurs.
///
/// Deux modes :
/// - `required = false` (défaut, depuis le splash) : bouton "Skip" disponible
/// - `required = true` (depuis le paywall) : pas de skip, l'utilisateur doit
///   se connecter pour continuer (ou backer)
///
/// Au signin success ou skip, navigue vers la prochaine étape :
/// - Si on vient du splash → OnboardingRoute (ou HomeRoute si déjà fait)
/// - Si on vient du paywall (`required = true`) → pop vers le paywall
@RoutePage()
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({this.required = false, super.key});

  /// Si true, masque le bouton "Continuer sans compte" — utilisé quand
  /// l'utilisateur est redirigé depuis le paywall.
  final bool required;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .track(AnalyticsEvent.authScreenViewed),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AuthScreenState state = ref.watch(authViewModelProvider);

    // Affiche un snackbar discret en cas d'erreur — listen, pas watch.
    ref.listen<AuthScreenState>(authViewModelProvider, (
      AuthScreenState? previous,
      AuthScreenState next,
    ) {
      if (next.error != null && previous?.error != next.error) {
        _showErrorSnackbar(context, next.error!.message);
      }
    });

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(CalmSpace.s7),
            child: Column(
              children: <Widget>[
                const Spacer(flex: 2),
                const BeedleIconAsset(size: 96),
                const Gap(CalmSpace.s7),
                Text(
                  LocaleKeys.auth_title.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(
                    color: AppColors.ink,
                    height: 1.1,
                  ),
                ),
                const Gap(CalmSpace.s4),
                Text(
                  LocaleKeys.auth_subtitle.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.neutral6,
                  ),
                ),
                const Spacer(flex: 3),
                AuthProviderButton(
                  label: LocaleKeys.auth_signin_apple.tr(),
                  variant: AuthProviderButtonVariant.apple,
                  loading: state.status == AuthScreenStatus.signingInApple,
                  onPressed: state.status == AuthScreenStatus.idle
                      ? () => _handleSignIn(context, isApple: true)
                      : null,
                ),
                const Gap(CalmSpace.s3),
                AuthProviderButton(
                  label: LocaleKeys.auth_signin_google.tr(),
                  variant: AuthProviderButtonVariant.google,
                  loading: state.status == AuthScreenStatus.signingInGoogle,
                  onPressed: state.status == AuthScreenStatus.idle
                      ? () => _handleSignIn(context, isApple: false)
                      : null,
                ),
                if (!widget.required) ...<Widget>[
                  const Gap(CalmSpace.s5),
                  TextButton(
                    onPressed: state.status == AuthScreenStatus.idle
                        ? () => _handleSkip(context)
                        : null,
                    child: Text(
                      LocaleKeys.auth_skip.tr(),
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.neutral7,
                      ),
                    ),
                  ),
                ],
                const Gap(CalmSpace.s4),
                Text(
                  LocaleKeys.auth_legal.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignIn(
    BuildContext context, {
    required bool isApple,
  }) async {
    final AuthViewModel vm = ref.read(authViewModelProvider.notifier);
    final bool ok = isApple
        ? await vm.signInWithApple()
        : await vm.signInWithGoogle();
    if (!ok) return;
    if (!context.mounted) return;
    await _navigateAfterAuth(context);
  }

  Future<void> _handleSkip(BuildContext context) async {
    await ref.read(authViewModelProvider.notifier).skip();
    if (!context.mounted) return;
    await _navigateAfterAuth(context);
  }

  /// Après signin success ou skip :
  /// - mode `required = true` (depuis paywall) → pop avec true
  /// - mode normal → replace par SplashRoute pour laisser le routing décider
  ///   de la suite (Onboarding ou Home selon `prefs.hasCompletedOnboarding`).
  Future<void> _navigateAfterAuth(BuildContext context) async {
    if (widget.required) {
      await context.router.maybePop(true);
    } else {
      await context.router.replace(const SplashRoute());
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        margin: const EdgeInsets.all(CalmSpace.s5),
        duration: const Duration(seconds: 3),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.canvas),
        ),
      ),
    );
  }
}
