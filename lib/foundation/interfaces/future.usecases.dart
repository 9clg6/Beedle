import 'dart:async';

import 'package:beedle/foundation/interfaces/results.usecases.dart';
import 'package:beedle/foundation/interfaces/usecase.interfaces.dart';
import 'package:beedle/foundation/logging/logger.dart';

const Duration _kDefaultTimeout = Duration(seconds: 25);

/// Use case asynchrone sans paramètres.
abstract class FutureUseCase<T> implements BaseUseCase<Future<ResultState<T>>> {
  /// Timeout appliqué à `invoke()`.
  Duration get timeout => _kDefaultTimeout;

  @override
  Future<ResultState<T>> execute() async =>
      _futureCatcher(invoke, name: runtimeType.toString(), timeout: timeout);

  /// Méthode à implémenter par les sous-classes.
  Future<T> invoke();
}

/// Use case asynchrone avec paramètres.
abstract class FutureUseCaseWithParams<T, P>
    implements BaseUseCaseWithParams<Future<ResultState<T>>, P> {
  /// Timeout appliqué à `invoke()`.
  Duration get timeout => _kDefaultTimeout;

  @override
  Future<ResultState<T>> execute(P params) async => _futureCatcher(
    () => invoke(params),
    name: runtimeType.toString(),
    timeout: timeout,
  );

  /// Méthode à implémenter par les sous-classes.
  Future<T> invoke(P params);
}

Future<ResultState<T>> _futureCatcher<T>(
  Future<T> Function() operation, {
  required String name,
  required Duration timeout,
}) async {
  final Log log = Log.named(name);
  try {
    final T result = await operation().timeout(timeout);
    return ResultState<T>.success(result);
  } on TimeoutException catch (e, st) {
    log.warn('Timeout after ${timeout.inSeconds}s', e, st);
    return ResultState<T>.failure(e);
  } on Exception catch (e, st) {
    log.error('Failed: $e', e, st);
    return ResultState<T>.failure(e);
  } catch (e, st) {
    log.error('Unexpected error: $e', e, st);
    return ResultState<T>.failure(Exception(e.toString()));
  }
}
