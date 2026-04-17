import 'package:beedle/foundation/config/app_config.dart';
import 'package:beedle/foundation/enum/environment.enum.dart';

/// Configuration de l'environnement de développement.
final class AppConfigDev extends AppConfig {
  const AppConfigDev()
    : super(
        appName: 'Beedle Dev',
        workerBaseUrl: 'https://beedle-proxy-dev.beedleapp.workers.dev',
        env: Environment.development,
        // TODO-USER: remplacer par les vraies clés RevenueCat sandbox.
        revenueCatApiKeyIos: 'appl_DEV_IOS_KEY_TODO',
        revenueCatApiKeyAndroid: 'goog_DEV_ANDROID_KEY_TODO',
      );
}
