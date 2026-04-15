import 'package:beedle/foundation/config/app_config.dart';
import 'package:beedle/foundation/enum/environment.enum.dart';

/// Configuration de l'environnement de production.
final class AppConfigProd extends AppConfig {
  const AppConfigProd()
      : super(
          appName: 'Beedle',
          workerBaseUrl: 'https://beedle-proxy.workers.dev',
          env: Environment.production,
          // TODO-USER: remplacer par les vraies clés RevenueCat prod.
          revenueCatApiKeyIos: 'appl_PROD_IOS_KEY_TODO',
          revenueCatApiKeyAndroid: 'goog_PROD_ANDROID_KEY_TODO',
          postHogApiKey: 'phc_PROD_TODO',
          postHogHost: 'https://eu.i.posthog.com',
        );
}
