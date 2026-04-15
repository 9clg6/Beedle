/// Interface de base pour tout use case sans paramètres.
abstract class BaseUseCase<R> {
  R execute();
}

/// Interface de base pour tout use case avec paramètres.
abstract class BaseUseCaseWithParams<R, P> {
  R execute(P params);
}
