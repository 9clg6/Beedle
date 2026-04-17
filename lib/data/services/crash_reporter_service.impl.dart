import 'package:beedle/domain/services/crash_reporter.service.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Implémentation [CrashReporterService] via Firebase Crashlytics.
///
/// Best-effort : toute exception du SDK est captée et loggée localement,
/// sans la propager vers l'appelant (le crash reporting ne doit jamais
/// bloquer un flow métier).
final class FirebaseCrashReporterService implements CrashReporterService {
  FirebaseCrashReporterService();

  final Log _log = Log.named('FirebaseCrashReporterService');

  @override
  Future<void> setUserIdentifier(String uid) async {
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(uid);
    } on Exception catch (e) {
      _log.warn('setUserIdentifier failed: $e');
    }
  }
}
