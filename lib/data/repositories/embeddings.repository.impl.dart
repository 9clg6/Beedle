import 'dart:collection';

import 'package:beedle/data/clients/worker_client.dart';
import 'package:beedle/domain/repositories/embeddings.repository.dart';
import 'package:beedle/foundation/exceptions/app_exceptions.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:dio/dio.dart';

/// Implémentation EmbeddingsRepository via Worker → OpenAI text-embedding-3-small.
///
/// Inclut un cache LRU de 20 entrées pour les queries répétées.
final class EmbeddingsRepositoryImpl implements EmbeddingsRepository {
  EmbeddingsRepositoryImpl({required WorkerClient workerClient})
      : _dio = workerClient.dio;

  final Dio _dio;
  final Log _log = Log.named('EmbeddingsRepository');
  final LinkedHashMap<String, List<double>> _cache = LinkedHashMap<String, List<double>>();

  static const int _maxCacheSize = 20;
  static const String _model = 'text-embedding-3-small';
  static const int _dim = 1536;

  @override
  Future<List<double>> embed(String text) async {
    if (text.trim().isEmpty) return List<double>.filled(_dim, 0);

    // Cache hit ?
    if (_cache.containsKey(text)) {
      final cached = _cache.remove(text);
      if (cached != null) {
        _cache[text] = cached; // refresh LRU
        return cached;
      }
    }

    try {
      final response = await _dio.post<dynamic>(
        '/v1/embeddings',
        data: <String, dynamic>{
          'model': _model,
          'input': text,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>;
      if (data.isEmpty) {
        throw const LLMException('Empty embeddings response');
      }
      final first = data.first as Map<String, dynamic>;
      final rawVector = first['embedding'] as List<dynamic>;
      final vector =
          rawVector.map((dynamic e) => (e as num).toDouble()).toList();

      _cache[text] = vector;
      if (_cache.length > _maxCacheSize) {
        _cache.remove(_cache.keys.first);
      }

      return vector;
    } on DioException catch (e) {
      _log.error('Embeddings failed: ${e.message}', e);
      throw LLMException('Embeddings request failed', cause: e, statusCode: e.response?.statusCode);
    } on Exception catch (e) {
      _log.error('Embeddings unexpected error: $e', e);
      throw LLMException('Embeddings unexpected error', cause: e);
    }
  }
}
