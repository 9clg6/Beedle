import 'dart:async';

import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/core/providers/service_providers.dart';
import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/ingestion_job.entity.dart';
import 'package:beedle/domain/enum/ingestion_status.enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// État d'affichage dérivé pour la `UploadProgressCard`.
///
/// Sealed class — chaque sous-type correspond à un rendu visuel distinct :
/// - [UploadDisplayIdle] : rien à montrer → card masquée.
/// - [UploadDisplayActive] : des captures sont en queued/processing → spinner.
/// - [UploadDisplayFailed] : au moins un job a échoué (non-dismissed) → rouge.
/// - [UploadDisplaySuccess] : une fiche vient d'être générée (affiché ~2.5s).
sealed class UploadDisplayState {
  const UploadDisplayState();
}

final class UploadDisplayIdle extends UploadDisplayState {
  const UploadDisplayIdle();
}

final class UploadDisplayActive extends UploadDisplayState {
  const UploadDisplayActive({required this.count});
  final int count;
}

final class UploadDisplayFailed extends UploadDisplayState {
  const UploadDisplayFailed({
    required this.jobUuids,
    required this.errorMessage,
    required this.count,
  });

  /// UUIDs de tous les jobs failed visibles (utile pour le dismiss groupé).
  final List<String> jobUuids;

  /// Message d'erreur du job failed le plus récent (pour l'afficher).
  final String errorMessage;

  /// Nombre de jobs failed regroupés dans la card.
  final int count;
}

final class UploadDisplaySuccess extends UploadDisplayState {
  const UploadDisplaySuccess({required this.cardTitle});
  final String cardTitle;
}

/// Set d'UUIDs de jobs failed que l'utilisateur a explicitement fermés via
/// le bouton "Fermer". Ces UUIDs sont filtrés du flux d'affichage pour
/// ne pas ré-apparaître tant que l'app vit. Reset naturellement au restart.
final NotifierProvider<DismissedFailedJobsNotifier, Set<String>>
dismissedFailedJobsProvider =
    NotifierProvider<DismissedFailedJobsNotifier, Set<String>>(
      DismissedFailedJobsNotifier.new,
    );

class DismissedFailedJobsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void dismiss(Iterable<String> uuids) {
    state = <String>{...state, ...uuids};
  }

  void restore(Iterable<String> uuids) {
    state = state.difference(uuids.toSet());
  }
}

/// Durée pendant laquelle l'état "success" reste visible après la réception
/// d'un `cardGeneratedStream`. Correspond au design : brief flash puis dismiss.
const Duration _kSuccessVisibleDuration = Duration(milliseconds: 2500);

/// Source de vérité UI pour l'upload progress card.
///
/// Combine :
/// 1. Le stream ObjectBox des jobs actifs + failed.
/// 2. Le stream `cardGeneratedStream` du pipeline pour basculer en "success".
/// 3. Le set des jobs failed dismissed pour filtrer.
///
/// Règles de priorité :
///   failed > active > success récent > idle
final StreamProvider<UploadDisplayState> uploadDisplayStateProvider =
    StreamProvider<UploadDisplayState>((Ref ref) {
      final Stream<List<IngestionJobEntity>> jobsStream = ref
          .watch(ingestionJobRepositoryProvider)
          .watchActiveAndFailed();
      final Stream<CardEntity> cardStream = ref
          .watch(ingestionPipelineServiceProvider)
          .cardGeneratedStream;

      final StreamController<UploadDisplayState> controller =
          StreamController<UploadDisplayState>();

      List<IngestionJobEntity> lastJobs = <IngestionJobEntity>[];
      String? recentSuccessTitle;
      Timer? successTimer;

      void recompute() {
        final Set<String> dismissed = ref.read(dismissedFailedJobsProvider);

        final List<IngestionJobEntity> failed = lastJobs
            .where(
              (IngestionJobEntity j) =>
                  j.status == IngestionStatus.failed &&
                  !dismissed.contains(j.uuid),
            )
            .toList();
        if (failed.isNotEmpty) {
          final IngestionJobEntity mostRecent = failed.reduce(
            (IngestionJobEntity a, IngestionJobEntity b) =>
                a.createdAt.isAfter(b.createdAt) ? a : b,
          );
          final int captureCount = failed.fold<int>(
            0,
            (int sum, IngestionJobEntity j) => sum + j.screenshotUuids.length,
          );
          controller.add(
            UploadDisplayFailed(
              jobUuids: failed.map((IngestionJobEntity j) => j.uuid).toList(),
              errorMessage:
                  mostRecent.lastError ?? 'Une erreur inconnue est survenue.',
              count: captureCount,
            ),
          );
          return;
        }

        final List<IngestionJobEntity> active = lastJobs
            .where(
              (IngestionJobEntity j) =>
                  j.status == IngestionStatus.queued ||
                  j.status == IngestionStatus.processing,
            )
            .toList();
        if (active.isNotEmpty) {
          final int captureCount = active.fold<int>(
            0,
            (int sum, IngestionJobEntity j) => sum + j.screenshotUuids.length,
          );
          controller.add(UploadDisplayActive(count: captureCount));
          return;
        }

        if (recentSuccessTitle != null) {
          controller.add(UploadDisplaySuccess(cardTitle: recentSuccessTitle!));
          return;
        }

        controller.add(const UploadDisplayIdle());
      }

      final StreamSubscription<List<IngestionJobEntity>> jobsSub = jobsStream
          .listen((List<IngestionJobEntity> list) {
            lastJobs = list;
            recompute();
          });

      final StreamSubscription<CardEntity> cardSub = cardStream.listen((
        CardEntity card,
      ) {
        recentSuccessTitle = card.title;
        successTimer?.cancel();
        successTimer = Timer(_kSuccessVisibleDuration, () {
          recentSuccessTitle = null;
          recompute();
        });
        recompute();
      });

      // Le provider doit aussi recomputer quand les dismissed changent.
      final ProviderSubscription<Set<String>> dismissedSub = ref
          .listen<Set<String>>(dismissedFailedJobsProvider, (
            Set<String>? _,
            Set<String> _,
          ) {
            recompute();
          });

      ref.onDispose(() {
        unawaited(jobsSub.cancel());
        unawaited(cardSub.cancel());
        dismissedSub.close();
        successTimer?.cancel();
        unawaited(controller.close());
      });

      return controller.stream;
    });
