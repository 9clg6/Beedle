import 'dart:async';
import 'dart:ui';

import 'package:beedle/app.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/kernel.provider.dart';
import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/firebase_options.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Point d'entrée logique — appelé depuis main().
///
/// 1. Bind widget binding
/// 2. Init Firebase (+ Crashlytics handlers)
/// 3. Init EasyLocalization
/// 4. Bootstrap ObjectBox
/// 5. Wire ProviderScope avec override du store
/// 6. Run l'app
/// 7. Finalize kernel dans un postframe (RevenueCat, notifs, pipeline…)
Future<void> bootstrap() async {
  final Log log = Log.named('Bootstrap');
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Crashlytics : envoie uniquement en release (debug = dev local).
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    kReleaseMode,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    unawaited(
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
    );
    return true;
  };

  await EasyLocalization.ensureInitialized();

  log.info('Bootstrapping ObjectBox...');
  final KernelBootstrap kernel = await bootstrapKernel();

  runApp(
    ProviderScope(
      overrides: <Override>[
        objectBoxStoreProvider.overrideWithValue(kernel.objectBoxStore),
      ],
      child: EasyLocalization(
        supportedLocales: const <Locale>[Locale('fr'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: _KernelFinalizer(
          store: kernel.objectBoxStore,
          child: const BeedleApp(),
        ),
      ),
    ),
  );
}

class _KernelFinalizer extends ConsumerStatefulWidget {
  const _KernelFinalizer({required this.store, required this.child});
  final ObjectBoxStore store;
  final Widget child;

  @override
  ConsumerState<_KernelFinalizer> createState() => _KernelFinalizerState();
}

class _KernelFinalizerState extends ConsumerState<_KernelFinalizer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await finalizeKernel(
        ref,
        onNotificationTap: _handleNotificationTap,
      );
    });
  }

  /// Deep-link handler for notification payloads :
  /// - `beedle://card/{uuid}` → CardDetailRoute
  /// - `beedle://import`      → ImportRoute
  void _handleNotificationTap(String payload) {
    final Log log = Log.named('NotificationTap');
    try {
      final Uri uri = Uri.parse(payload);
      if (uri.scheme != 'beedle') return;

      final AppRouter router = AppRouter.instance;
      if (uri.host == 'card' && uri.pathSegments.isNotEmpty) {
        final String uuid = uri.pathSegments.first;
        unawaited(router.push(CardDetailRoute(uuid: uuid)));
      } else if (uri.host == 'import') {
        unawaited(router.push(const ImportRoute()));
      } else if (uri.host == 'lesson') {
        unawaited(router.push(const TodayRoute()));
      }
    } on Exception catch (e) {
      log.warn('Failed to route payload "$payload": $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
