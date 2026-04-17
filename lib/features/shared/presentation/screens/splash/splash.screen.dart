import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/auth.provider.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/domain/entities/auth_user.entity.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/generated/locale_keys.g.dart';
import 'package:beedle/presentation/widgets/beedle_icon_asset.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Splash : decide si on va en OB ou en home selon UserPreferences.onboardingCompletedAt.
@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    final UserPreferencesEntity prefs = await ref
        .read(userPreferencesRepositoryProvider)
        .load();
    final AuthUserEntity? user = ref.read(authServiceProvider).currentUser;

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Auth resolution : signed-in OU explicitement skipped.
    final bool authResolved = user != null || prefs.authSkippedAt != null;
    if (!authResolved) {
      await context.router.replace(AuthRoute());
      return;
    }

    if (prefs.hasCompletedOnboarding) {
      await context.router.replace(const HomeRoute());
    } else {
      await context.router.replace(const OnboardingRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _LogoMark(),
              const SizedBox(height: 24),
              Text(
                LocaleKeys.app_name.tr(),
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                LocaleKeys.app_tagline.tr(),
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo mark du splash = l'app icon "Dot-b" rendu en grand (96 pts).
///
/// Remplace l'ancien placeholder `Icons.auto_awesome` sur cercle gradient.
/// Cohérent avec l'app icon iOS/Android qui sera générée depuis le même
/// design source — voir `docs/brainstorming-app-icon-2026-04-16.md` et
/// `assets/branding/icon-dot-b.svg`.
class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return const BeedleIconAsset();
  }
}
