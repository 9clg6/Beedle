/// Contrat d'accès à un stockage clé-valeur typé.
abstract interface class StorageInterface<T> {
  /// Lit une valeur ou retourne null.
  Future<T?> read();

  /// Écrit la valeur.
  Future<void> write(T value);

  /// Supprime la valeur.
  Future<void> delete();
}
