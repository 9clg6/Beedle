import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Implémentation [AnalyticsService] via Firebase Analytics.
///
/// Consent-guarded : si `setConsent(false)`, la collecte est désactivée
/// au niveau du SDK (rien ne quitte l'appareil).
final class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final Log _log = Log.named('FirebaseAnalyticsService');

  bool _consent = true;
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      // Firebase Analytics est auto-initialisé via Firebase.initializeApp().
      // On respecte juste l'état de consent par défaut.
      await _analytics.setAnalyticsCollectionEnabled(_consent);
      _initialized = true;
      _log.info('Firebase Analytics initialized (consent=$_consent)');
    } on Exception catch (e) {
      _log.warn('Firebase Analytics init failed: $e');
    }
  }

  @override
  Future<void> setConsent(bool consent) async {
    _consent = consent;
    await _analytics.setAnalyticsCollectionEnabled(consent);
  }

  @override
  Future<void> identify({required Map<String, Object> properties}) async {
    if (!_consent) return;
    try {
      final Object? distinctId = properties['distinct_id'];
      if (distinctId != null) {
        await _analytics.setUserId(id: distinctId.toString());
      }
      for (final MapEntry<String, Object> entry in properties.entries) {
        if (entry.key == 'distinct_id') continue;
        await _analytics.setUserProperty(
          name: entry.key,
          value: entry.value.toString(),
        );
      }
    } on Exception catch (e) {
      if (kDebugMode) _log.warn('identify failed: $e');
    }
  }

  @override
  Future<void> track(String event, {Map<String, Object>? properties}) async {
    if (!_consent) return;
    try {
      await _analytics.logEvent(
        name: event,
        parameters: properties?.cast<String, Object>(),
      );
    } on Exception catch (e) {
      if (kDebugMode) _log.warn('track $event failed: $e');
    }
  }

  @override
  Future<void> reset() async {
    try {
      await _analytics.resetAnalyticsData();
    } on Exception catch (e) {
      _log.warn('reset failed: $e');
    }
  }
}
