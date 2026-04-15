import 'package:auto_route/auto_route.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/presentation/theme/app_colors.dart';
import 'package:beedle/presentation/widgets/gradient_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beedle/generated/locale_keys.g.dart';

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
    final prefs = await ref.read(userPreferencesRepositoryProvider).load();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (prefs.hasCompletedOnboarding) {
      await context.router.replace(const HomeRoute());
    } else {
      await context.router.replace(const OnboardingRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x55B794F4),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
    );
  }
}
