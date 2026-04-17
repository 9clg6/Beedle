/// Intent d'une card — détermine comment elle est surfacée par Beedle.
///
/// - [apply]     — actionnable, à tester (prompt, méthode, outil, recette).
///                 Éligible pour Daily Lesson + push teasers.
/// - [read]      — à lire/comprendre (concept, explication, essai).
///                 Éligible pour Voice Terminal (reflection/observation).
/// - [reference] — documentation à garder (snippet, cheatsheet, liste).
///                 JAMAIS poussée, jamais en Daily Lesson.
///
/// Détecté par le LLM à la digestion. Peut être override manuellement par
/// l'user (via CardEntity.intentOverridden = true) — dans ce cas le LLM
/// ne re-classe pas lors d'un re-digest (fusion).
enum CardIntent {
  apply,
  read,
  reference
  ;

  static CardIntent fromString(String? value) {
    return CardIntent.values.firstWhere(
      (CardIntent e) => e.name == value,
      orElse: () => CardIntent.read, // default safe — backward compat.
    );
  }
}
