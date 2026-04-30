import 'package:beedle/foundation/config/app_config.dart';
import 'package:beedle/foundation/enum/environment.enum.dart';

/// Configuration de l'environnement de production.
final class AppConfigProd extends AppConfig {
  const AppConfigProd()
    : super(
        appName: 'Beedle',
        // TODO-USER: remplacer par l'URL d'un Worker Cloudflare prod dédié
        // (ex: https://beedle-proxy.beedleapp.workers.dev) une fois déployé.
        // En attendant, on pointe sur le Worker dev qui existe réellement —
        // sinon les builds release échouent avec "Failed host lookup" car
        // l'ancienne URL `beedle-proxy.workers.dev` n'est pas déployée.
        workerBaseUrl: 'https://beedle-proxy-dev.beedleapp.workers.dev',
        env: Environment.production,
        revenueCatApiKeyIos: 'appl_ffiLeSkyMhzlprfaiTjAyunkmpf',
        revenueCatApiKeyAndroid: 'goog_YSzzPQUhDMYVkRChbaFPMjfABdv',
      );
}
