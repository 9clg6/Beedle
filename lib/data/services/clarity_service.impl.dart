import 'package:beedle/domain/services/clarity.service.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/foundation.dart';

/// Project ID Clarity — dashboard Settings.
const String _kBeedleClarityProjectId = 'weo1nhhhs6';

/// Implémentation [ClarityService] via le SDK officiel
/// `clarity_flutter`.
///
/// Le SDK s'initialise automatiquement quand l'app est wrappée dans
/// [ClarityWidget]. Cette classe sert surtout à exposer le consent côté
/// domain + centraliser le projectId pour bootstrap.
final class MicrosoftClarityService implements ClarityService {
  MicrosoftClarityService();

  final Log _log = Log.named('ClarityService');
  bool _consent = true;

  @override
  String get projectId => _kBeedleClarityProjectId;

  @override
  Future<void> setConsent(bool consent) async {
    _consent = consent;
    try {
      // Clarity expose `Clarity.pause()` / `Clarity.resume()` pour gater
      // la collecte sans reconfigurer le SDK.
      if (consent) {
        Clarity.resume();
      } else {
        Clarity.pause();
      }
    } on Object catch (e) {
      if (kDebugMode) _log.warn('Clarity setConsent failed: $e');
    }
  }

  /// Config réutilisée au bootstrap pour wrapper l'app dans [ClarityWidget].
  ClarityConfig buildConfig() {
    return ClarityConfig(
      projectId: projectId,
      logLevel: kReleaseMode ? LogLevel.None : LogLevel.Warn,
    );
  }

  /// Expose le flag consent en lecture pour les callers bootstrap.
  bool get consent => _consent;
}
