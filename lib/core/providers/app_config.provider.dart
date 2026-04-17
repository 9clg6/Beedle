import 'package:beedle/foundation/config/app_config.dart';
import 'package:beedle/foundation/config/impl/app_config.dev.dart';
import 'package:beedle/foundation/config/impl/app_config.prod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider de l'AppConfig courante.
///
/// Résolution : dev en mode debug, prod en release. Utiliser `--dart-define`
/// pour override si besoin (ex: staging).
final Provider<AppConfig> appConfigProvider = Provider<AppConfig>((Ref ref) {
  if (kReleaseMode) {
    return const AppConfigProd();
  }
  return const AppConfigDev();
});
