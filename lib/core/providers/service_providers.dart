import 'package:beedle/core/providers/app_config.provider.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/data/services/analytics_service.impl.dart';
import 'package:beedle/data/services/data_management.service.impl.dart';
import 'package:beedle/data/services/local_notification_engine.impl.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/domain/services/fusion_engine.service.dart';
import 'package:beedle/domain/services/gamification_engine.service.dart';
import 'package:beedle/domain/services/ingestion_pipeline.service.dart';
import 'package:beedle/domain/services/notification_scheduler.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<FusionEngine> fusionEngineProvider = Provider<FusionEngine>((ref) {
  return FusionEngine(
    screenshotRepository: ref.watch(screenshotRepositoryProvider),
    cardRepository: ref.watch(cardRepositoryProvider),
  );
});

final Provider<GamificationEngine> gamificationEngineProvider =
    Provider<GamificationEngine>((ref) {
  return GamificationEngine(
    gamificationRepository: ref.watch(gamificationRepositoryProvider),
    cardRepository: ref.watch(cardRepositoryProvider),
  );
});

final Provider<IngestionPipelineService> ingestionPipelineServiceProvider =
    Provider<IngestionPipelineService>((ref) {
  final service = IngestionPipelineService(
    screenshotRepository: ref.watch(screenshotRepositoryProvider),
    ingestionJobRepository: ref.watch(ingestionJobRepositoryProvider),
    cardRepository: ref.watch(cardRepositoryProvider),
    ocrRepository: ref.watch(ocrRepositoryProvider),
    llmRepository: ref.watch(llmRepositoryProvider),
    embeddingsRepository: ref.watch(embeddingsRepositoryProvider),
    userPreferencesRepository: ref.watch(userPreferencesRepositoryProvider),
    fusionEngine: ref.watch(fusionEngineProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final Provider<LocalNotificationEngineImpl> localNotificationEngineProvider =
    Provider<LocalNotificationEngineImpl>((ref) {
  return LocalNotificationEngineImpl();
});

final Provider<LocalNotificationEngine> localNotificationEngineInterfaceProvider =
    Provider<LocalNotificationEngine>((ref) {
  return ref.watch(localNotificationEngineProvider);
});

final Provider<NotificationSchedulerService> notificationSchedulerServiceProvider =
    Provider<NotificationSchedulerService>((ref) {
  return NotificationSchedulerService(
    cardRepository: ref.watch(cardRepositoryProvider),
    notificationRecordRepository: ref.watch(notificationRecordRepositoryProvider),
    localNotificationEngine: ref.watch(localNotificationEngineInterfaceProvider),
    appConfig: ref.watch(appConfigProvider),
  );
});

final Provider<AnalyticsService> analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return PostHogAnalyticsService(config: ref.watch(appConfigProvider));
});

final Provider<DataManagementService> dataManagementServiceProvider =
    Provider<DataManagementService>((ref) {
  return DataManagementService(
    cardDataSource: ref.watch(cardLocalDataSourceProvider),
    screenshotDataSource: ref.watch(screenshotLocalDataSourceProvider),
    ingestionJobDataSource: ref.watch(ingestionJobLocalDataSourceProvider),
    notificationRecordDataSource: ref.watch(notificationRecordLocalDataSourceProvider),
    userPreferencesDataSource: ref.watch(userPreferencesLocalDataSourceProvider),
    subscriptionDataSource: ref.watch(subscriptionSnapshotLocalDataSourceProvider),
    gamificationDataSource: ref.watch(gamificationLocalDataSourceProvider),
    analyticsService: ref.watch(analyticsServiceProvider),
  );
});
