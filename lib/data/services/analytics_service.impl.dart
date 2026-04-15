import 'package:beedle/domain/services/analytics.service.dart';
import 'package:beedle/foundation/config/app_config.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Implémentation AnalyticsService via PostHog (région EU).
///
/// Consent-guarded : si `setConsent(false)`, rien n'est envoyé.
final class PostHogAnalyticsService implements AnalyticsService {
  PostHogAnalyticsService({required AppConfig config}) : _config = config;

  final AppConfig _config;
  final Log _log = Log.named('PostHogAnalyticsService');

  bool _consent = true;
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    try {
      // Note: PostHog config is also set in native iOS/Android files; this
      // Dart-level init is a noop once platforms are configured via
      // PostHogConfig in AppDelegate/MainActivity as per the Flutter SDK docs.
      // TODO-USER: configurer PostHog dans ios/Runner/AppDelegate.swift et
      //            android/app/src/main/AndroidManifest.xml avec la clé PostHog.
      _initialized = true;
      _log.info('PostHog initialized (key=${_config.postHogApiKey.substring(0, 6)}...)');
    } on Exception catch (e) {
      _log.warn('PostHog init failed: $e');
    }
  }

  @override
  Future<void> setConsent(bool consent) async {
    _consent = consent;
    if (!consent) {
      await Posthog().disable();
    } else {
      await Posthog().enable();
    }
  }

  @override
  Future<void> identify({required Map<String, Object> properties}) async {
    if (!_consent) return;
    try {
      await Posthog().identify(
        userId: properties['distinct_id']?.toString() ?? 'anonymous',
        userProperties: properties,
      );
    } on Exception catch (e) {
      if (kDebugMode) _log.warn('identify failed: $e');
    }
  }

  @override
  Future<void> track(String event, {Map<String, Object>? properties}) async {
    if (!_consent) return;
    try {
      await Posthog().capture(eventName: event, properties: properties);
    } on Exception catch (e) {
      if (kDebugMode) _log.warn('track $event failed: $e');
    }
  }

  @override
  Future<void> reset() async {
    try {
      await Posthog().reset();
    } on Exception catch (e) {
      _log.warn('reset failed: $e');
    }
  }
}
