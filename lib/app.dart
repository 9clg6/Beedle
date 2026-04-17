import 'package:beedle/foundation/routing/app_router.dart';
import 'package:beedle/presentation/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shell applicatif — MaterialApp.router + theme + localizations.
class BeedleApp extends ConsumerStatefulWidget {
  const BeedleApp({super.key});

  @override
  ConsumerState<BeedleApp> createState() => _BeedleAppState();
}

class _BeedleAppState extends ConsumerState<BeedleApp> {
  final AppRouter _router = AppRouter.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Beedle',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode
          .light, // CalmSurface light-first — dark à raffiner plus tard.
      routerConfig: _router.config(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
