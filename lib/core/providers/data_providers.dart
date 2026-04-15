import 'package:beedle/core/providers/app_config.provider.dart';
import 'package:beedle/data/clients/objectbox_store.dart';
import 'package:beedle/data/clients/worker_client.dart';
import 'package:beedle/data/datasources/local/card.local.data_source.dart';
import 'package:beedle/data/datasources/local/impl/card.local.data_source.impl.dart';
import 'package:beedle/data/datasources/local/impl/ingestion_job.local.data_source.impl.dart';
import 'package:beedle/data/datasources/local/impl/notification_record.local.data_source.impl.dart';
import 'package:beedle/data/datasources/local/impl/screenshot.local.data_source.impl.dart';
import 'package:beedle/data/datasources/local/ingestion_job.local.data_source.dart';
import 'package:beedle/data/datasources/local/notification_record.local.data_source.dart';
import 'package:beedle/data/datasources/local/screenshot.local.data_source.dart';
import 'package:beedle/data/datasources/local/subscription_snapshot.local.data_source.dart';
import 'package:beedle/data/datasources/local/user_preferences.local.data_source.dart';
import 'package:beedle/data/datasources/local/gamification.local.data_source.dart';
import 'package:beedle/data/repositories/card.repository.impl.dart';
import 'package:beedle/data/repositories/embeddings.repository.impl.dart';
import 'package:beedle/data/repositories/gamification.repository.impl.dart';
import 'package:beedle/data/repositories/ingestion_job.repository.impl.dart';
import 'package:beedle/data/repositories/llm.repository.impl.dart';
import 'package:beedle/data/repositories/notification.repository.impl.dart';
import 'package:beedle/data/repositories/ocr.repository.impl.dart';
import 'package:beedle/data/repositories/screenshot.repository.impl.dart';
import 'package:beedle/data/repositories/subscription.repository.impl.dart';
import 'package:beedle/data/repositories/user_preferences.repository.impl.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/domain/repositories/embeddings.repository.dart';
import 'package:beedle/domain/repositories/gamification.repository.dart';
import 'package:beedle/domain/repositories/ingestion_job.repository.dart';
import 'package:beedle/domain/repositories/llm.repository.dart';
import 'package:beedle/domain/repositories/notification.repository.dart';
import 'package:beedle/domain/repositories/ocr.repository.dart';
import 'package:beedle/domain/repositories/screenshot.repository.dart';
import 'package:beedle/domain/repositories/subscription.repository.dart';
import 'package:beedle/domain/repositories/user_preferences.repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fichier regroupant les providers de la couche data (clients + datasources + repositories).
///
/// Divergence vs ARCHITECTURE.md : l'architecture demande 1 provider par fichier.
/// Pour le MVP solo dev, on groupe pour réduire l'overhead. Voir ADR-001.

// ============================================================================
// Clients (keepAlive — singletons au boot).
// ============================================================================

/// ObjectBox store — initialisé dans le kernel provider.
final Provider<ObjectBoxStore> objectBoxStoreProvider =
    Provider<ObjectBoxStore>((ref) {
  throw UnimplementedError(
    'objectBoxStoreProvider must be overridden in ProviderScope after bootstrap.',
  );
});

/// Worker Cloudflare (LLM + Embeddings proxy).
final Provider<WorkerClient> workerClientProvider = Provider<WorkerClient>((ref) {
  final client = WorkerClient(config: ref.watch(appConfigProvider));
  return client;
});

// ============================================================================
// Data sources.
// ============================================================================

final Provider<CardLocalDataSource> cardLocalDataSourceProvider =
    Provider<CardLocalDataSource>((ref) {
  return CardLocalDataSourceImpl(store: ref.watch(objectBoxStoreProvider));
});

final Provider<ScreenshotLocalDataSource> screenshotLocalDataSourceProvider =
    Provider<ScreenshotLocalDataSource>((ref) {
  return ScreenshotLocalDataSourceImpl(store: ref.watch(objectBoxStoreProvider));
});

final Provider<IngestionJobLocalDataSource> ingestionJobLocalDataSourceProvider =
    Provider<IngestionJobLocalDataSource>((ref) {
  return IngestionJobLocalDataSourceImpl(store: ref.watch(objectBoxStoreProvider));
});

final Provider<NotificationRecordLocalDataSource>
    notificationRecordLocalDataSourceProvider =
    Provider<NotificationRecordLocalDataSource>((ref) {
  return NotificationRecordLocalDataSourceImpl(
      store: ref.watch(objectBoxStoreProvider),);
});

final Provider<UserPreferencesLocalDataSource>
    userPreferencesLocalDataSourceProvider =
    Provider<UserPreferencesLocalDataSource>((ref) {
  return UserPreferencesLocalDataSourceImpl(
      store: ref.watch(objectBoxStoreProvider),);
});

final Provider<SubscriptionSnapshotLocalDataSource>
    subscriptionSnapshotLocalDataSourceProvider =
    Provider<SubscriptionSnapshotLocalDataSource>((ref) {
  return SubscriptionSnapshotLocalDataSourceImpl(
      store: ref.watch(objectBoxStoreProvider),);
});

final Provider<GamificationLocalDataSource> gamificationLocalDataSourceProvider =
    Provider<GamificationLocalDataSource>((ref) {
  return GamificationLocalDataSourceImpl(store: ref.watch(objectBoxStoreProvider));
});

// ============================================================================
// Repositories (domain interfaces → impls).
// ============================================================================

final Provider<CardRepository> cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepositoryImpl(
    cardLocalDataSource: ref.watch(cardLocalDataSourceProvider),
    subscriptionSnapshotLocalDataSource:
        ref.watch(subscriptionSnapshotLocalDataSourceProvider),
  );
});

final Provider<ScreenshotRepository> screenshotRepositoryProvider =
    Provider<ScreenshotRepository>((ref) {
  return ScreenshotRepositoryImpl(
    screenshotLocalDataSource: ref.watch(screenshotLocalDataSourceProvider),
  );
});

final Provider<IngestionJobRepository> ingestionJobRepositoryProvider =
    Provider<IngestionJobRepository>((ref) {
  return IngestionJobRepositoryImpl(
    dataSource: ref.watch(ingestionJobLocalDataSourceProvider),
  );
});

final Provider<NotificationRecordRepository> notificationRecordRepositoryProvider =
    Provider<NotificationRecordRepository>((ref) {
  return NotificationRecordRepositoryImpl(
    dataSource: ref.watch(notificationRecordLocalDataSourceProvider),
  );
});

final Provider<UserPreferencesRepository> userPreferencesRepositoryProvider =
    Provider<UserPreferencesRepository>((ref) {
  return UserPreferencesRepositoryImpl(
    dataSource: ref.watch(userPreferencesLocalDataSourceProvider),
  );
});

final Provider<SubscriptionRepository> subscriptionRepositoryProvider =
    Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(
    dataSource: ref.watch(subscriptionSnapshotLocalDataSourceProvider),
    appConfig: ref.watch(appConfigProvider),
  );
});

final Provider<LLMRepository> llmRepositoryProvider = Provider<LLMRepository>((ref) {
  return LLMRepositoryImpl(workerClient: ref.watch(workerClientProvider));
});

final Provider<EmbeddingsRepository> embeddingsRepositoryProvider =
    Provider<EmbeddingsRepository>((ref) {
  return EmbeddingsRepositoryImpl(workerClient: ref.watch(workerClientProvider));
});

final Provider<OCRRepository> ocrRepositoryProvider = Provider<OCRRepository>((ref) {
  final impl = OCRRepositoryImpl();
  ref.onDispose(impl.dispose);
  return impl;
});

final Provider<GamificationRepository> gamificationRepositoryProvider =
    Provider<GamificationRepository>((ref) {
  return GamificationRepositoryImpl(
    dataSource: ref.watch(gamificationLocalDataSourceProvider),
  );
});
