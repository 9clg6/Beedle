import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/presentation/theme/app_theme.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shell applicatif — MaterialApp.router + theme + localizations + Clarity.
///
/// Clarity est wrappé ici (pas au-dessus de `ProviderScope` dans bootstrap)
/// pour que le SDK capture l'arbre widget complet incluant les dialogs
/// Riverpod. Le FirebaseAnalyticsObserver est attaché au router pour
/// auto-tracker les screen_view.
class BeedleApp extends ConsumerStatefulWidget {
  const BeedleApp({super.key});

  @override
  ConsumerState<BeedleApp> createState() => _BeedleAppState();
}

class _BeedleAppState extends ConsumerState<BeedleApp> {
  final AppRouter _router = AppRouter.instance;

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalyticsObserver analyticsObserver = ref.watch(
      firebaseAnalyticsObserverProvider,
    );
    final ClarityConfig clarityConfig = ref
        .watch(clarityServiceImplProvider)
        .buildConfig();

    final Widget app = MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Beedle',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode
          .light, // CalmSurface light-first — dark à raffiner plus tard.
      routerConfig: _router.config(
        navigatorObservers: () => <NavigatorObserver>[analyticsObserver],
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );

    return ClarityWidget(app: app, clarityConfig: clarityConfig);
  }
}
