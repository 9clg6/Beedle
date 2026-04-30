import 'package:beedle/core/providers/app_config.provider.dart';
import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/data/services/analytics_service.impl.dart';
import 'package:beedle/data/services/clarity_service.impl.dart';
import 'package:beedle/data/services/crash_reporter_service.impl.dart';
import 'package:beedle/data/services/data_management.service.impl.dart';
import 'package:beedle/data/services/local_notification_engine.impl.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/domain/services/clarity.service.dart';
import 'package:beedle/domain/services/crash_reporter.service.dart';
import 'package:beedle/domain/services/daily_lesson.service.dart';
import 'package:beedle/domain/services/engagement_scheduler.service.dart';
import 'package:beedle/domain/services/fusion_engine.service.dart';
import 'package:beedle/domain/services/gamification_engine.service.dart';
import 'package:beedle/domain/services/ingestion_pipeline.service.dart';
import 'package:beedle/domain/services/notification_scheduler.service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<FusionEngine> fusionEngineProvider = Provider<FusionEngine>((
  Ref ref,
) {
  return FusionEngine(
    screenshotRepository: ref.watch(screenshotRepositoryProvider),
    cardRepository: ref.watch(cardRepositoryProvider),
  );
});

final Provider<GamificationEngine> gamificationEngineProvider =
    Provider<GamificationEngine>((Ref ref) {
      return GamificationEngine(
        gamificationRepository: ref.watch(gamificationRepositoryProvider),
        cardRepository: ref.watch(cardRepositoryProvider),
      );
    });

final Provider<IngestionPipelineService> ingestionPipelineServiceProvider =
    Provider<IngestionPipelineService>((Ref ref) {
      final IngestionPipelineService service = IngestionPipelineService(
        screenshotRepository: ref.watch(screenshotRepositoryProvider),
        ingestionJobRepository: ref.watch(ingestionJobRepositoryProvider),
        cardRepository: ref.watch(cardRepositoryProvider),
        ocrRepository: ref.watch(ocrRepositoryProvider),
        llmRepository: ref.watch(llmRepositoryProvider),
        embeddingsRepository: ref.watch(embeddingsRepositoryProvider),
        userPreferencesRepository: ref.watch(userPreferencesRepositoryProvider),
        fusionEngine: ref.watch(fusionEngineProvider),
        engagementMessageRepository: ref.watch(
          engagementMessageRepositoryProvider,
        ),
        subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
        screenshotStorageRepository: ref.watch(
          screenshotStorageRepositoryProvider,
        ),
        crashReporter: ref.watch(crashReporterServiceProvider),
        analytics: ref.watch(analyticsServiceProvider),
      );
      ref.onDispose(service.dispose);
      return service;
    });

final Provider<LocalNotificationEngineImpl> localNotificationEngineProvider =
    Provider<LocalNotificationEngineImpl>((Ref ref) {
      return LocalNotificationEngineImpl();
    });

final Provider<LocalNotificationEngine>
localNotificationEngineInterfaceProvider = Provider<LocalNotificationEngine>((
  Ref ref,
) {
  return ref.watch(localNotificationEngineProvider);
});

final Provider<DailyLessonService> dailyLessonServiceProvider =
    Provider<DailyLessonService>((Ref ref) {
      return DailyLessonService(
        cardRepository: ref.watch(cardRepositoryProvider),
      );
    });

final Provider<EngagementSchedulerService> engagementSchedulerServiceProvider =
    Provider<EngagementSchedulerService>((Ref ref) {
      return EngagementSchedulerService(
        engagementMessageRepository: ref.watch(
          engagementMessageRepositoryProvider,
        ),
        cardRepository: ref.watch(cardRepositoryProvider),
      );
    });

final Provider<NotificationSchedulerService>
notificationSchedulerServiceProvider = Provider<NotificationSchedulerService>((
  Ref ref,
) {
  return NotificationSchedulerService(
    cardRepository: ref.watch(cardRepositoryProvider),
    notificationRecordRepository: ref.watch(
      notificationRecordRepositoryProvider,
    ),
    localNotificationEngine: ref.watch(
      localNotificationEngineInterfaceProvider,
    ),
    appConfig: ref.watch(appConfigProvider),
    engagementScheduler: ref.watch(engagementSchedulerServiceProvider),
    dailyLessonService: ref.watch(dailyLessonServiceProvider),
  );
});

final Provider<AnalyticsService> analyticsServiceProvider =
    Provider<AnalyticsService>((Ref ref) {
      return FirebaseAnalyticsService();
    });

/// Singleton Clarity — wrappé dans `ClarityWidget` au bootstrap.
final Provider<MicrosoftClarityService> clarityServiceImplProvider =
    Provider<MicrosoftClarityService>((Ref ref) {
      return MicrosoftClarityService();
    });

final Provider<ClarityService> clarityServiceProvider =
    Provider<ClarityService>(
      (Ref ref) => ref.watch(clarityServiceImplProvider),
    );

/// [FirebaseAnalyticsObserver] branché sur `MaterialApp.router` pour
/// auto-tracker les `screen_view` à chaque push/replace/pop de route.
///
/// Nommage dérivé de la route AutoRoute (ex: `HomeRoute` → `Home`).
final Provider<FirebaseAnalyticsObserver> firebaseAnalyticsObserverProvider =
    Provider<FirebaseAnalyticsObserver>((Ref ref) {
      return FirebaseAnalyticsObserver(
        analytics: FirebaseAnalytics.instance,
      );
    });

final Provider<CrashReporterService> crashReporterServiceProvider =
    Provider<CrashReporterService>((Ref ref) {
      return FirebaseCrashReporterService();
    });

final Provider<DataManagementService> dataManagementServiceProvider =
    Provider<DataManagementService>((Ref ref) {
      return DataManagementService(
        cardDataSource: ref.watch(cardLocalDataSourceProvider),
        screenshotDataSource: ref.watch(screenshotLocalDataSourceProvider),
        ingestionJobDataSource: ref.watch(ingestionJobLocalDataSourceProvider),
        notificationRecordDataSource: ref.watch(
          notificationRecordLocalDataSourceProvider,
        ),
        userPreferencesDataSource: ref.watch(
          userPreferencesLocalDataSourceProvider,
        ),
        subscriptionDataSource: ref.watch(
          subscriptionSnapshotLocalDataSourceProvider,
        ),
        gamificationDataSource: ref.watch(gamificationLocalDataSourceProvider),
        analyticsService: ref.watch(analyticsServiceProvider),
      );
    });
