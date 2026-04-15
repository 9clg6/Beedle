/// Badges débloquables dans Beedle (Tier 2 gamification).
enum BadgeType {
  // Milestones volume.
  firstImport, // 1er screenshot importé
  collector50, // 50 fiches
  collector200, // 200 fiches

  // Milestones application.
  firstTest, // 1re fiche testée
  apprentice, // 5 tests
  sensei, // 25 tests

  // Consultation.
  deepDive, // 3 fiches consultées plus d'une fois
  archaeologist, // Consulté une fiche > 30 jours

  // Streaks.
  streak3, // 3 jours consécutifs
  streak7, // 1 semaine
  streak30, // 1 mois

  // Rythme d'usage.
  earlyBird, // Actif avant 9h, 5 fois
  nightOwl, // Actif entre 20h et 22h, 5 fois

  // Diversité.
  polyglot, // Cards consultées dans les deux langues (fr + en)

  // Défis hebdos.
  challengeRookie, // 1er défi hebdo complété
  challengeStreak3; // 3 défis hebdos consécutifs complétés

  String get icon {
    switch (this) {
      case BadgeType.firstImport:
        return '📸';
      case BadgeType.collector50:
        return '📚';
      case BadgeType.collector200:
        return '🏛️';
      case BadgeType.firstTest:
        return '🌱';
      case BadgeType.apprentice:
        return '🧪';
      case BadgeType.sensei:
        return '🥋';
      case BadgeType.deepDive:
        return '🔍';
      case BadgeType.archaeologist:
        return '⚱️';
      case BadgeType.streak3:
        return '🔥';
      case BadgeType.streak7:
        return '🔥🔥';
      case BadgeType.streak30:
        return '🏆';
      case BadgeType.earlyBird:
        return '🐦';
      case BadgeType.nightOwl:
        return '🦉';
      case BadgeType.polyglot:
        return '🌍';
      case BadgeType.challengeRookie:
        return '🎯';
      case BadgeType.challengeStreak3:
        return '🎖️';
    }
  }

  static BadgeType fromString(String value) {
    return BadgeType.values.firstWhere(
      (b) => b.name == value,
      orElse: () => BadgeType.firstImport,
    );
  }
}
