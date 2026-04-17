import 'package:beedle/foundation/interfaces/usecase.interfaces.dart';

/// Use case streaming sans paramètres.
abstract class StreamUseCase<T> implements BaseUseCase<Stream<T>> {
  @override
  Stream<T> execute() => invoke();

  Stream<T> invoke();
}

/// Use case streaming avec paramètres.
abstract class StreamUseCaseWithParams<T, P>
    implements BaseUseCaseWithParams<Stream<T>, P> {
  @override
  Stream<T> execute(P params) => invoke(params);

  Stream<T> invoke(P params);
}
