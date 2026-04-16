import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/digestion_result.entity.dart';
import 'package:beedle/domain/entities/engagement_message.entity.dart';
import 'package:beedle/domain/entities/ingestion_job.entity.dart';
import 'package:beedle/domain/entities/screenshot.entity.dart';
import 'package:beedle/domain/entities/user_preferences.entity.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';
import 'package:beedle/domain/params/generate_card.param.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/domain/repositories/embeddings.repository.dart';
import 'package:beedle/domain/repositories/engagement_message.repository.dart';
import 'package:beedle/domain/repositories/ingestion_job.repository.dart';
import 'package:beedle/domain/repositories/llm.repository.dart';
import 'package:beedle/domain/repositories/ocr.repository.dart';
import 'package:beedle/domain/repositories/screenshot.repository.dart';
import 'package:beedle/domain/repositories/user_preferences.repository.dart';
import 'package:beedle/domain/services/fusion_engine.service.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

/// Orchestrateur du pipeline capture → OCR → fusion → LLM → embedding → persist
///
/// C'est le cœur de Beedle. Il tourne en arrière-plan, picke des
/// [IngestionJobEntity] dans la queue ObjectBox, et émet un event sur
final class IngestionPipelineService {
  IngestionPipelineService({
    required ScreenshotRepository screenshotRepository,
    required IngestionJobRepository ingestionJobRepository,
    required CardRepository cardRepository,
    required OCRRepository ocrRepository,
    required LLMRepository llmRepository,
    required EmbeddingsRepository embeddingsRepository,
    required UserPreferencesRepository userPreferencesRepository,
    required FusionEngine fusionEngine,
    required EngagementMessageRepository engagementMessageRepository,
  }) : _screenshotRepository = screenshotRepository,
       _ingestionJobRepository = ingestionJobRepository,
       _cardRepository = cardRepository,
       _ocrRepository = ocrRepository,
       _llmRepository = llmRepository,
       _embeddingsRepository = embeddingsRepository,
       _userPreferencesRepository = userPreferencesRepository,
       _fusionEngine = fusionEngine,
       _engagementMessageRepository = engagementMessageRepository;

  final ScreenshotRepository _screenshotRepository;
  final IngestionJobRepository _ingestionJobRepository;
  final CardRepository _cardRepository;
  final OCRRepository _ocrRepository;
  final LLMRepository _llmRepository;
  final EmbeddingsRepository _embeddingsRepository;
  final UserPreferencesRepository _userPreferencesRepository;
  final FusionEngine _fusionEngine;
  final EngagementMessageRepository _engagementMessageRepository;

  final Log _log = Log.named('IngestionPipeline');
  final Uuid _uuid = const Uuid();

  /// Résout la langue preferred depuis prefs.uiLanguage.
  /// - `'fr'` / `'en'` → forcé
  /// - `'system'` → prend le locale system (fr ou en selon le téléphone)
  /// - tout autre → fallback `'auto'` (LLM détecte)
  String _resolvePreferredLang(String uiLanguage) {
    if (uiLanguage == 'fr' || uiLanguage == 'en') return uiLanguage;
    if (uiLanguage == 'system') {
      final String systemLang = PlatformDispatcher.instance.locale.languageCode;
      if (systemLang == 'fr' || systemLang == 'en') return systemLang;
    }
    return 'auto';
  }

  /// Stream émis à chaque Card générée (succès complet).
  final BehaviorSubject<CardEntity> cardGeneratedStream =
      BehaviorSubject<CardEntity>();

  bool _running = false;

  /// Démarre le worker en continu — à appeler une seule fois au bootstrap.
  Future<void> start() async {
    if (_running) return;
    _running = true;
    _log.info('Started pipeline worker.');
    unawaited(_loop());
  }

  Future<void> stop() async {
    _running = false;
  }

  Future<void> _loop() async {
    while (_running) {
      try {
        final IngestionJobEntity? job = await _ingestionJobRepository
            .nextPending();
        if (job == null) {
          await Future<void>.delayed(const Duration(seconds: 3));
          continue;
        }
        await _processJob(job);
      } on Exception catch (e, st) {
        _log.error('Worker loop error: $e', e, st);
        await Future<void>.delayed(const Duration(seconds: 5));
      }
    }
  }

  /// Traite un job individuel. Public pour permettre aux triggers (WorkManager)
  /// de forcer le processing de toute la queue en foreground.
  Future<void> processNext() async {
    final IngestionJobEntity? job = await _ingestionJobRepository.nextPending();
    if (job == null) return;
    await _processJob(job);
  }

  Future<void> _processJob(IngestionJobEntity job) async {
    await _ingestionJobRepository.updateStatus(
      job.uuid,
      IngestionStatus.processing,
    );

    try {
      // 1. OCR sur chaque screenshot.
      // Defensive : si le fichier source a disparu (image_picker purgé par iOS
      // après reboot/kill app), on skip plutôt que de planter ML Kit en natif.
      // Le job entier bascule failed si aucun screenshot n'est exploitable.
      final List<ScreenshotEntity> screenshots = <ScreenshotEntity>[];
      int missingFiles = 0;
      for (final String sUuid in job.screenshotUuids) {
        final ScreenshotEntity? s = await _screenshotRepository.getByUuid(
          sUuid,
        );
        if (s == null) continue;
        if (!File(s.filePath).existsSync()) {
          _log.warn('Screenshot file missing: ${s.filePath} (uuid=${s.uuid})');
          missingFiles++;
          continue;
        }
        final OCRResult ocr = await _ocrRepository.extract(s.filePath);
        final ScreenshotEntity updated = s.copyWith(
          ocrText: ocr.text,
          ocrConfidence: ocr.confidence,
          detectedLanguage: ocr.detectedLanguage,
        );
        await _screenshotRepository.upsert(updated);
        screenshots.add(updated);
      }

      if (screenshots.isEmpty) {
        throw Exception(
          missingFiles > 0
              ? 'Captures introuvables — ont été supprimées ou déplacées ($missingFiles fichier(s) manquant(s))'
              : 'No screenshots found for job ${job.uuid}',
        );
      }

      // 2. Fusion check — est-ce qu'on ajoute à une Card existante ?
      String? fusionTargetUuid;
      if (screenshots.length == 1) {
        fusionTargetUuid = await _fusionEngine.findFusionCandidate(
          screenshots.first,
        );
      }

      // 3. Concaténer le texte OCR de tous les screenshots (+ fusion éventuelle).
      String combinedText = screenshots
          .map((ScreenshotEntity s) => s.ocrText)
          .join('\n---\n');
      CardEntity? existing;
      if (fusionTargetUuid != null) {
        existing = await _cardRepository.getByUuid(fusionTargetUuid);
        if (existing != null) {
          final List<ScreenshotEntity> existingScreens =
              await _screenshotRepository.getByCardUuid(existing.uuid);
          final String previous = existingScreens
              .map((ScreenshotEntity s) => s.ocrText)
              .join('\n---\n');
          combinedText = '$previous\n---\n$combinedText';
        }
      }

      // 4. Charger préférences user (quiz answers) pour personnaliser le prompt.
      final UserPreferencesEntity prefs = await _userPreferencesRepository
          .load();

      // 5. Appel LLM — force la langue de l'app si définie (fr/en), sinon auto.
      final String preferredLang = _resolvePreferredLang(prefs.uiLanguage);
      final DigestionResultEntity digestion = await _llmRepository.digest(
        GenerateCardParam(
          ocrText: combinedText,
          userCategories: prefs.contentCategories,
          preferredLanguage: preferredLang,
        ),
      );

      // 6. Embedding sur le fullContent + title + tags — couvre tout le corpus
      //    pour une recherche sémantique fine.
      final String embeddingSource =
          '${digestion.title}\n${digestion.tags.join(' ')}\n${digestion.fullContent}';
      final List<double> embedding = await _embeddingsRepository.embed(
        embeddingSource,
      );

      // Cancel check : si l'utilisateur a supprimé le job via la card
      // (bouton Annuler) pendant l'OCR / LLM / embedding, on abort avant
      // de persister la card. Les screenshots OCRisés restent en base
      // (harmless orphans) mais aucune card visible n'est créée et aucun
      // event `cardGeneratedStream` n'est émis.
      final IngestionJobEntity? stillExists = await _ingestionJobRepository
          .getByUuid(job.uuid);
      if (stillExists == null) {
        _log.info('Job ${job.uuid} was cancelled mid-pipeline — aborting.');
        return;
      }

      // 7. Persister la Card (création ou update si fusion).
      //    Si existing.intentOverridden → on préserve l'intent utilisateur.
      final bool preserveIntent = existing?.intentOverridden ?? false;
      final CardEntity card = CardEntity(
        uuid: existing?.uuid ?? _uuid.v4(),
        title: digestion.title,
        summary: digestion.summary,
        fullContent: digestion.fullContent,
        level: digestion.level,
        tags: digestion.tags,
        language: digestion.language,
        teaserHook: digestion.teaserHook,
        status: IngestionStatus.completed,
        createdAt: existing?.createdAt ?? DateTime.now(),
        estimatedMinutes: digestion.estimatedMinutes,
        sourceUrl: digestion.sourceUrl,
        embedding: embedding,
        viewedCount: existing?.viewedCount ?? 0,
        viewedAt: existing?.viewedAt,
        testedAt: existing?.testedAt,
        intent: preserveIntent ? existing!.intent : digestion.intent,
        intentOverridden: preserveIntent,
        primaryAction: digestion.primaryAction,
      );
      final CardEntity saved = await _cardRepository.upsert(card);

      // 7.b Persister les engagementMessages pré-générés (pool Beedle's Voice).
      //     En cas de fusion, on purge ceux de l'ancienne card + remplace.
      if (existing != null) {
        await _engagementMessageRepository.deleteByCardUuid(existing.uuid);
      }
      final DateTime now = DateTime.now();
      final List<EngagementMessageEntity> messages = digestion
          .engagementMessages
          .map(
            (DigestedEngagementMessage m) => EngagementMessageEntity(
              uuid: _uuid.v4(),
              cardUuid: saved.uuid,
              content: m.content,
              type: m.type,
              format: m.format,
              delayDays: m.delayDays,
              createdAt: now,
            ),
          )
          .toList(growable: false);
      if (messages.isNotEmpty) {
        await _engagementMessageRepository.saveAll(messages);
        _log.info(
          'Persisted ${messages.length} engagement messages for card ${saved.uuid}',
        );
      }

      // 8. Linker les screenshots à la Card.
      for (final ScreenshotEntity s in screenshots) {
        await _screenshotRepository.linkToCard(s.uuid, saved.uuid);
      }

      await _ingestionJobRepository.updateStatus(
        job.uuid,
        IngestionStatus.completed,
        cardUuid: saved.uuid,
      );

      cardGeneratedStream.add(saved);
      _log.info('Card generated: ${saved.title} (${saved.uuid})');
    } on Exception catch (e, st) {
      _log.error('Job ${job.uuid} failed: $e', e, st);
      await _ingestionJobRepository.updateStatus(
        job.uuid,
        IngestionStatus.failed,
        error: e.toString(),
      );
    }
  }

  Future<void> dispose() async {
    await stop();
    await cardGeneratedStream.close();
  }
}
