import 'package:auto_route/auto_route.dart';
import 'package:beedle/features/capture/presentation/screens/import/import.screen.dart';
import 'package:beedle/features/card_detail/presentation/screens/card_detail.screen.dart';
import 'package:beedle/features/gamification/presentation/screens/dashboard.screen.dart';
import 'package:beedle/features/home/presentation/screens/home.screen.dart';
import 'package:beedle/features/onboarding/presentation/screens/onboarding.screen.dart';
import 'package:beedle/features/paywall/presentation/screens/paywall.screen.dart';
import 'package:beedle/features/search/presentation/screens/search.screen.dart';
import 'package:beedle/features/settings/presentation/screens/settings.screen.dart';
import 'package:beedle/features/shared/presentation/screens/splash/splash.screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

part 'app_router.gr.dart';

/// Router racine Beedle (AutoRoute).
@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter({super.navigatorKey});

  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: OnboardingRoute.page),
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: CardDetailRoute.page, path: '/card/:uuid'),
        AutoRoute(page: ImportRoute.page),
        AutoRoute(page: SearchRoute.page),
        AutoRoute(page: SettingsRoute.page),
        AutoRoute(page: PaywallRoute.page),
        AutoRoute(page: DashboardRoute.page),
      ];
}
