import 'dart:async';

import 'package:beedle/domain/services/analytics.service.dart';
import 'package:dio/dio.dart';

/// Dio interceptor qui loggue chaque appel API sortant en analytics.
///
/// Firebase Analytics impose des noms d'events ≤ 40 chars et des noms
/// de params ≤ 40 chars. On tronque l'URL et on normalise l'endpoint
/// pour dédupliquer (ex: `/digest/<uuid>` → `/digest/*`).
class AnalyticsInterceptor extends Interceptor {
  AnalyticsInterceptor({required AnalyticsService analytics})
    : _analytics = analytics;

  final AnalyticsService _analytics;
  static const String _stopwatchKey = '_analytics_started_at';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.extra[_stopwatchKey] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logCall(
      options: response.requestOptions,
      status: response.statusCode ?? 0,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logCall(
      options: err.requestOptions,
      status: err.response?.statusCode ?? 0,
      error: err.type.name,
    );
    unawaited(
      _analytics.track(
        AnalyticsEvent.apiError,
        properties: <String, Object>{
          'endpoint': _normalizePath(err.requestOptions.path),
          'method': err.requestOptions.method,
          'status': err.response?.statusCode ?? 0,
          'error_type': err.type.name,
        },
      ),
    );
    handler.next(err);
  }

  void _logCall({
    required RequestOptions options,
    required int status,
    String? error,
  }) {
    final DateTime? started = options.extra[_stopwatchKey] as DateTime?;
    final int durationMs = started == null
        ? 0
        : DateTime.now().difference(started).inMilliseconds;
    final Map<String, Object> props = <String, Object>{
      'endpoint': _normalizePath(options.path),
      'method': options.method,
      'status': status,
      'duration_ms': durationMs,
    };
    if (error != null) props['error_type'] = error;
    unawaited(_analytics.track(AnalyticsEvent.apiCall, properties: props));
  }

  /// Remplace les segments UUID/hex/numériques par `*` pour garder un
  /// cardinalité d'endpoints bornée (Firebase facture au param unique).
  static String _normalizePath(String path) {
    final Iterable<String> segments = Uri.parse(path).pathSegments.map((
      String s,
    ) {
      if (s.isEmpty) return s;
      final bool looksLikeId =
          RegExp(r'^[0-9a-fA-F-]{8,}$').hasMatch(s) ||
          RegExp(r'^\d+$').hasMatch(s);
      return looksLikeId ? '*' : s;
    });
    final String normalized = '/${segments.join('/')}';
    return normalized.length <= 100 ? normalized : normalized.substring(0, 100);
  }
}
