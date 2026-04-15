import 'package:beedle/foundation/config/app_config.dart';
import 'package:dio/dio.dart';

/// Dio client typé pour le Cloudflare Worker proxy (LLM + Embeddings).
///
/// L'auth se fait via le header `X-User-Id` (App User ID RevenueCat, anonyme).
/// Aucune clé OpenAI ne transite par le device.
class WorkerClient {
  WorkerClient({required AppConfig config}) : _dio = _buildDio(config);

  final Dio _dio;

  Dio get dio => _dio;

  /// Met à jour l'identifiant utilisateur (utilisé pour le rate-limit Worker).
  void setUserId(String? userId) {
    if (userId == null) {
      _dio.options.headers.remove('X-User-Id');
    } else {
      _dio.options.headers['X-User-Id'] = userId;
    }
  }

  /// Met à jour le tier (free | pro) pour rate-limiting côté Worker.
  void setUserTier(String tier) {
    _dio.options.headers['X-User-Tier'] = tier;
  }

  static Dio _buildDio(AppConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.workerBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      ),
    );
    return dio;
  }
}
