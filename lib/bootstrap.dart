import 'dart:async';

import 'package:beedle/app.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/kernel.provider.dart';
import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/framework.dart';

/// Point d'entrée logique — appelé depuis main().
///
/// 1. Bind widget binding
/// 2. Init EasyLocalization
/// 3. Bootstrap ObjectBox
/// 4. Wire ProviderScope avec override du store
/// 5. Run l'app
/// 6. Finalize kernel dans un postframe (RevenueCat, notifs, pipeline…)
Future<void> bootstrap() async {
  final log = Log.named('Bootstrap');
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  log.info('Bootstrapping ObjectBox...');
  final kernel = await bootstrapKernel();

  runApp(
    ProviderScope(
      overrides: <Override>[
        objectBoxStoreProvider.overrideWithValue(kernel.objectBoxStore),
      ],
      child: EasyLocalization(
        supportedLocales: const <Locale>[Locale('fr'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: _KernelFinalizer(store: kernel.objectBoxStore, child: const BeedleApp()),
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
        onNotificationTap: (payload) {
          // TODO-USER: router le payload via AppRouter (deep-link → Card detail ou Import).
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
