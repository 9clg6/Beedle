/// Types de défi hebdomadaire.
enum ChallengeType {
  /// Tester X astuces cette semaine.
  testN,

  /// Consulter X fiches non vues depuis > 30 jours.
  reviveOld,

  /// Maintenir un streak de X jours consécutifs.
  streakN
  ;

  static ChallengeType fromString(String value) {
    return ChallengeType.values.firstWhere(
      (ChallengeType t) => t.name == value,
      orElse: () => ChallengeType.testN,
    );
  }
}
