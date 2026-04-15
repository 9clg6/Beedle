/// Résultat d'un use case : succès ou échec.
class ResultState<T> {
  ResultState._({this.data, this.exception});

  /// Crée un résultat de succès.
  factory ResultState.success(T data) => ResultState<T>._(data: data);

  /// Crée un résultat d'échec.
  factory ResultState.failure(Exception exception) =>
      ResultState<T>._(exception: exception);

  final T? data;
  final Exception? exception;

  bool get isSuccess => exception == null;
  bool get isFailure => exception != null;

  /// Applique un callback selon le résultat.
  R? when<R>({
    R Function(T data)? success,
    R Function(Exception exception)? failure,
  }) {
    if (isSuccess && success != null) {
      return success(data as T);
    }
    if (isFailure && failure != null) {
      return failure(exception!);
    }
    return null;
  }
}
