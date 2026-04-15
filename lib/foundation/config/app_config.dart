import 'package:beedle/foundation/enum/environment.enum.dart';

/// Configuration abstraite de l'application.
abstract class AppConfig {
  const AppConfig({
    required this.appName,
    required this.workerBaseUrl,
    required this.env,
    required this.revenueCatApiKeyIos,
    required this.revenueCatApiKeyAndroid,
    required this.postHogApiKey,
    required this.postHogHost,
  });

  /// Environnement courant.
  final Environment env;

  /// Nom de l'application.
  final String appName;

  /// URL du Worker Cloudflare (LLM + Embeddings proxy).
  final String workerBaseUrl;

  /// Clé publique RevenueCat iOS.
  final String revenueCatApiKeyIos;

  /// Clé publique RevenueCat Android.
  final String revenueCatApiKeyAndroid;

  /// Clé publique PostHog.
  final String postHogApiKey;

  /// Host PostHog (EU).
  final String postHogHost;

  /// Indique si c'est la production.
  bool get isProd => env == Environment.production;

  /// Cap freemium mensuel de génération de fiches.
  int get freemiumMonthlyCap => 10;

  /// Cap freemium de push-teaser / jour.
  int get freemiumTeasersPerDay => 1;

  /// Cap volume max de fiches (NFR-007).
  int get maxCardsSoftCap => 1000;
}
