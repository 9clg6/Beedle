import 'package:beedle/domain/entities/card.entity.dart';
import 'package:beedle/domain/entities/screenshot.entity.dart';
import 'package:beedle/domain/repositories/card.repository.dart';
import 'package:beedle/domain/repositories/screenshot.repository.dart';
import 'package:beedle/foundation/logging/logger.dart';

/// Moteur de fusion multi-screenshots.
///
/// Heuristique (FR-006, TD-04) :
/// - Fenêtre temporelle : les screens pris dans les 5 dernières minutes sont
///   candidats à l'agrégation.
/// - Similarité Jaccard ≥ 40 % sur les tokens OCR → même contenu, fusionner.
/// - Si match : on rattache à la Card existante. Sinon : nouvelle Card.
final class FusionEngine {
  FusionEngine({
    required ScreenshotRepository screenshotRepository,
    required CardRepository cardRepository,
  })  : _screenshotRepository = screenshotRepository,
        _cardRepository = cardRepository;

  final ScreenshotRepository _screenshotRepository;
  final CardRepository _cardRepository;
  final Log _log = Log.named('FusionEngine');

  static const Duration _kWindow = Duration(minutes: 5);
  static const double _kJaccardThreshold = 0.4;

  /// Retourne l'UUID d'une Card existante à laquelle rattacher [newScreenshot],
  /// ou null si une nouvelle Card doit être créée.
  Future<String?> findFusionCandidate(ScreenshotEntity newScreenshot) async {
    if (newScreenshot.ocrText.trim().isEmpty) return null;

    final recent = await _screenshotRepository.getRecent();
    final newTokens = _tokenize(newScreenshot.ocrText);
    if (newTokens.isEmpty) return null;

    for (final candidate in recent) {
      if (candidate.uuid == newScreenshot.uuid) continue;
      if (candidate.cardUuid == null) continue;

      final candTokens = _tokenize(candidate.ocrText);
      if (candTokens.isEmpty) continue;

      final jaccard = _jaccard(newTokens, candTokens);
      if (jaccard >= _kJaccardThreshold) {
        _log.info('Fusion candidate found (jaccard=${jaccard.toStringAsFixed(2)}) → ${candidate.cardUuid}');
        // Vérifie que la Card existe toujours.
        final existing = await _cardRepository.getByUuid(candidate.cardUuid!);
        if (existing != null) return existing.uuid;
      }
    }

    return null;
  }

  Set<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]+'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .toSet();
  }

  double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final inter = a.intersection(b).length;
    final union = a.union(b).length;
    return inter / union;
  }
}
