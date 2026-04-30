import 'package:beedle/foundation/config/app_config.dart';
import 'package:beedle/foundation/enum/environment.enum.dart';

/// Configuration de l'environnement de développement.
final class AppConfigDev extends AppConfig {
  const AppConfigDev()
    : super(
        appName: 'Beedle Dev',
        workerBaseUrl: 'https://beedle-proxy-dev.beedleapp.workers.dev',
        env: Environment.development,
        revenueCatApiKeyIos: 'appl_ffiLeSkyMhzlprfaiTjAyunkmpf',
        revenueCatApiKeyAndroid: 'goog_YSzzPQUhDMYVkRChbaFPMjfABdv',
      );
}
