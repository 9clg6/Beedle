import 'dart:convert';
import 'dart:io';

import 'package:beedle/data/datasources/local/card.local.data_source.dart';
import 'package:beedle/data/datasources/local/gamification.local.data_source.dart';
import 'package:beedle/data/datasources/local/ingestion_job.local.data_source.dart';
import 'package:beedle/data/datasources/local/notification_record.local.data_source.dart';
import 'package:beedle/data/datasources/local/screenshot.local.data_source.dart';
import 'package:beedle/data/datasources/local/subscription_snapshot.local.data_source.dart';
import 'package:beedle/data/datasources/local/user_preferences.local.data_source.dart';
import 'package:beedle/data/mappers/card.mapper.dart';
import 'package:beedle/data/mappers/screenshot.mapper.dart';
import 'package:beedle/data/model/local/card.local.model.dart';
import 'package:beedle/data/model/local/screenshot.local.model.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/screenshot.entity.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/domain/usecases/export_all_data.use_case.dart';
import 'package:beedle/domain/usecases/wipe_all_data.use_case.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Service d'export + wipe des données locales.
final class DataManagementService implements DataExportService, DataWipeService {
  DataManagementService({
    required CardLocalDataSource cardDataSource,
    required ScreenshotLocalDataSource screenshotDataSource,
    required IngestionJobLocalDataSource ingestionJobDataSource,
    required NotificationRecordLocalDataSource notificationRecordDataSource,
    required UserPreferencesLocalDataSource userPreferencesDataSource,
    required SubscriptionSnapshotLocalDataSource subscriptionDataSource,
    required GamificationLocalDataSource gamificationDataSource,
    required AnalyticsService analyticsService,
  })  : _cardDataSource = cardDataSource,
        _screenshotDataSource = screenshotDataSource,
        _ingestionJobDataSource = ingestionJobDataSource,
        _notificationRecordDataSource = notificationRecordDataSource,
        _userPreferencesDataSource = userPreferencesDataSource,
        _subscriptionDataSource = subscriptionDataSource,
        _gamificationDataSource = gamificationDataSource,
        _analyticsService = analyticsService;

  final CardLocalDataSource _cardDataSource;
  final ScreenshotLocalDataSource _screenshotDataSource;
  final IngestionJobLocalDataSource _ingestionJobDataSource;
  final NotificationRecordLocalDataSource _notificationRecordDataSource;
  final UserPreferencesLocalDataSource _userPreferencesDataSource;
  final SubscriptionSnapshotLocalDataSource _subscriptionDataSource;
  final GamificationLocalDataSource _gamificationDataSource;
  final AnalyticsService _analyticsService;

  final Log _log = Log.named('DataManagementService');

  @override
  Future<String> exportAsJson() async {
    final cards = await _cardDataSource.getAll();
    final cardEntities = cards.map((e) => e.toEntity()).toList();
    final screenshots = <List<ScreenshotEntity>>[];
    for (final c in cardEntities) {
      final list = await _screenshotDataSource.getByCardUuid(c.uuid);
      screenshots.add(list.map((e) => e.toEntity()).toList());
    }

    final export = <String, dynamic>{
      'exportedAt': DateTime.now().toIso8601String(),
      'schemaVersion': 1,
      'cards': <Map<String, dynamic>>[
        for (int i = 0; i < cardEntities.length; i++)
          <String, dynamic>{
            'uuid': cardEntities[i].uuid,
            'title': cardEntities[i].title,
            'summary': cardEntities[i].summary,
            'fullContent': cardEntities[i].fullContent,
            'level': cardEntities[i].level.name,
            'tags': cardEntities[i].tags,
            'language': cardEntities[i].language,
            'teaserHook': cardEntities[i].teaserHook,
            'createdAt': cardEntities[i].createdAt.toIso8601String(),
            'viewedAt': cardEntities[i].viewedAt?.toIso8601String(),
            'testedAt': cardEntities[i].testedAt?.toIso8601String(),
            'sourceUrl': cardEntities[i].sourceUrl,
            'estimatedMinutes': cardEntities[i].estimatedMinutes,
            'screenshots': screenshots[i].map((s) => <String, dynamic>{
                  'uuid': s.uuid,
                  'capturedAt': s.capturedAt.toIso8601String(),
                  'ocrText': s.ocrText,
                  'sha256': s.sha256,
                }).toList(),
          },
      ],
    };

    final json = const JsonEncoder.withIndent('  ').convert(export);
    final tmp = await getTemporaryDirectory();
    final file = File(p.join(tmp.path, 'beedle-export-${DateTime.now().millisecondsSinceEpoch}.json'));
    await file.writeAsString(json);
    _log.info('Exported ${cardEntities.length} cards to ${file.path}');
    return file.path;
  }

  @override
  Future<void> wipeAll() async {
    _log.warn('Wiping all local data');
    await _cardDataSource.wipe();
    await _screenshotDataSource.wipe();
    await _ingestionJobDataSource.wipe();
    await _notificationRecordDataSource.wipe();
    await _userPreferencesDataSource.wipe();
    await _subscriptionDataSource.wipe();
    await _gamificationDataSource.wipe();
    await _analyticsService.reset();
  }
}
