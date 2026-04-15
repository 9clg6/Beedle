abstract interface class EmbeddingsRepository {
  /// Calcule l'embedding dim=1536 pour un texte.
  Future<List<double>> embed(String text);
}
