import 'dart:async';

import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/core/providers/usecase_providers.dart';
import 'package:beedle/domain/entities/ingestion_job.entity.dart';
import 'package:beedle/domain/params/import_screenshot.param.dart';
import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/foundation/interfaces/results.usecases.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:beedle/foundation/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Écoute les images partagées vers Beedle depuis le share sheet système
/// (iOS ShareExtension, Android SEND intent) et les injecte dans le même
/// pipeline que l'import manuel (ImportScreenshotsUseCase).
///
/// Deux entrées :
/// - cold start : `getInitialMedia()` (app lancée par le share)
/// - warm      : `getMediaStream()` (app déjà en foreground/background)
class ShareIntakeService {
  ShareIntakeService(this._ref);

  final WidgetRef _ref;
  final Log _log = Log.named('ShareIntake');
  StreamSubscription<List<SharedMediaFile>>? _sub;

  Future<void> start() async {
    // 1. Cold start.
    final List<SharedMediaFile> initial = await ReceiveSharingIntent.instance
        .getInitialMedia();
    if (initial.isNotEmpty) {
      unawaited(_handle(initial));
    }

    // 2. Stream pour app déjà ouverte.
    _sub = ReceiveSharingIntent.instance.getMediaStream().listen(
      _handle,
      onError: (Object e) => _log.warn('Share stream error: $e'),
    );
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> _handle(List<SharedMediaFile> files) async {
    // Beedle ne digère que des images (screenshots). On ignore tout le reste.
    final List<String> imagePaths = files
        .where((SharedMediaFile f) => f.type == SharedMediaType.image)
        .map((SharedMediaFile f) => f.path)
        .toList();

    if (imagePaths.isEmpty) {
      _log.info('Share reçu mais aucune image — ignoré.');
      unawaited(ReceiveSharingIntent.instance.reset());
      return;
    }

    _log.info('Share reçu : ${imagePaths.length} image(s) → ingestion.');

    final ResultState<IngestionJobEntity> result = await _ref
        .read(importScreenshotsUseCaseProvider)
        .execute(ImportScreenshotParam(filePaths: imagePaths));

    result.when(
      success: (_) {
        unawaited(
          _ref
              .read(analyticsServiceProvider)
              .track(
                AnalyticsEvent.capturedViaShare,
                properties: <String, Object>{'count': imagePaths.length},
              ),
        );
        unawaited(_ref.read(ingestionPipelineServiceProvider).processNext());
        unawaited(AppRouter.instance.push(const ImportRoute()));
      },
      failure: (Exception e) {
        unawaited(
          _ref
              .read(analyticsServiceProvider)
              .track(
                AnalyticsEvent.captureFailed,
                properties: <String, Object>{
                  'source': 'share',
                  'reason': e.runtimeType.toString(),
                },
              ),
        );
        _log.warn('Share → import failed: $e');
      },
    );

    // Nettoie le buffer natif pour éviter de re-traiter au prochain
    // `getInitialMedia`.
    unawaited(ReceiveSharingIntent.instance.reset());
  }
}
