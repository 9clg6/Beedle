import 'package:beedle/core/providers/app_config.provider.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/data/services/local_notification_engine.impl.dart';
import 'package:beedle/domain/entities/subscription_snapshot.entity.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/domain/services/ingestion_pipeline.service.dart';
import 'package:beedle/domain/services/notification_scheduler.service.dart';
import 'package:beedle/foundation/config/app_config.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

/// État booté de l'app — singleton, utilisé par main.dart pour
///  overrider les providers.
class KernelBootstrap {
  const KernelBootstrap({required this.objectBoxStore});
  final ObjectBoxStore objectBoxStore;
}

/// Étape 1 du bootstrap : créer le store ObjectBox avant runApp.
Future<KernelBootstrap> bootstrapKernel() async {
  final ObjectBoxStore store = await ObjectBoxStore.create();
  return KernelBootstrap(objectBoxStore: store);
}

/// Étape 2 : configurer les dépendances qui nécessitent `ref`
/// (RevenueCat, notifications, analytics, pipeline worker).
Future<void> finalizeKernel(
  WidgetRef ref, {
  required void Function(String payload) onNotificationTap,
}) async {
  final Log log = Log.named('Kernel')..info('Finalizing kernel...');

  // 1. AppConfig.
  final AppConfig config = ref.read(appConfigProvider);

  // 2. Analytics.
  final AnalyticsService analytics = ref.read(analyticsServiceProvider);
  await analytics.init();

  // 3. RevenueCat (best-effort : skip silencieux si clés placeholder).
  try {
    if (!config.revenueCatApiKeyIos.contains('TODO') &&
        !config.revenueCatApiKeyAndroid.contains('TODO')) {
      final rc.PurchasesConfiguration configuration = rc.PurchasesConfiguration(
        // On choisit la clé selon la plateforme.
        _resolveRcKey(config),
      );
      await rc.Purchases.configure(configuration);
    } else {
      log.warn(
        'RevenueCat skipped — placeholder keys detected. Configure'
        ' AppConfig to enable.',
      );
    }
  } on Exception catch (e) {
    log.warn('RevenueCat config failed: $e');
  }

  // 4. Sync initial de l'abonnement (best-effort).
  try {
    await ref.read(subscriptionRepositoryProvider).refresh();
  } on Exception catch (e) {
    log.warn('Subscription refresh failed: $e');
  }

  // 5. Worker client : inject user id.
  final SubscriptionSnapshotEntity subSnapshot = await ref
      .read(subscriptionRepositoryProvider)
      .load();
  ref.read(workerClientProvider)
    ..setUserId(subSnapshot.appUserId)
    ..setUserTier(subSnapshot.tier.name);

  // 6. Notifications locales.
  final LocalNotificationEngineImpl engine = ref.read(
    localNotificationEngineProvider,
  );
  await engine.init(onTap: onNotificationTap);

  // 7. Démarrer le pipeline d'ingestion.
  final IngestionPipelineService pipeline = ref.read(
    ingestionPipelineServiceProvider,
  );
  await pipeline.start();

  // 8. Planifier Daily Lesson + teasers selon prefs (best-effort).
  try {
    final UserPreferencesEntity prefs = await ref
        .read(userPreferencesRepositoryProvider)
        .load();
    final NotificationSchedulerService scheduler = ref.read(
      notificationSchedulerServiceProvider,
    );
    await scheduler.scheduleDailyLesson(prefs: prefs);
    await scheduler.scheduleTeasersForToday(
      prefs: prefs,
      subscription: subSnapshot,
    );
  } on Exception catch (e) {
    log.warn('Notification scheduling failed: $e');
  }

  log.info('Kernel ready.');
}

String _resolveRcKey(AppConfig config) {
  // À l'appel, on ne connaît pas la plateforme ici ; RevenueCat SDK gère les 2.
  // On prioritise iOS par défaut — le SDK sélectionne en fonction de Platform.isIOS/Android en interne.
  return config.revenueCatApiKeyIos;
}
