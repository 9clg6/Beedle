/// Objectif principal déclaré par l'utilisateur en onboarding (single-select).
///
/// Sert uniquement pour le branding du flow + analytics — non persisté
/// dans `UserPreferencesEntity`.
enum OnboardingGoal {
  buildFaster,
  stayAIUpToDate,
  rememberTutorials,
  findInfoFast,
  shareWithTeam,
  exploring,
}
