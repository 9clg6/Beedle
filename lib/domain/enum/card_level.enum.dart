/// Niveau de difficulté estimé d'une fiche.
enum CardLevel {
  beginner,
  intermediate,
  advanced,
  unknown
  ;

  static CardLevel fromString(String? value) {
    if (value == null) return CardLevel.unknown;
    return CardLevel.values.firstWhere(
      (CardLevel e) => e.name == value.toLowerCase(),
      orElse: () => CardLevel.unknown,
    );
  }
}
