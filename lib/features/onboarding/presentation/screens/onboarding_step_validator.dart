import 'package:beedle/features/onboarding/presentation/screens/onboarding.state.dart';

/// Nombre total d'écrans dans le flow questionnaire (indices 0..14).
const int kOnboardingTotalScreens = 15;

/// Index du dernier écran (cap pour [`OnboardingViewModel.next()`]).
const int kOnboardingLastIndex = kOnboardingTotalScreens - 1;

/// Indices "full immersion" — pas de NavBar, l'écran auto-pilote l'avance.
///
/// - 0  : Welcome → CTA dans la page
/// - 11 : Processing → auto-advance après 2 s
/// - 13 : Viral moment → CTAs Share / Continuer dans la page
const Set<int> kFullImmersionSteps = <int>{0, 11, 13};

/// Indices "auto-advance" — le widget gère lui-même la sortie de l'écran
/// (auto-advance, CTAs internes…). La NavBar n'expose pas *Continuer*.
///
/// - 3  : Tinder → next() quand les 5 cards ont été swipées
/// - 14 : Paywall → CTAs *Démarrer l'essai* / *Continuer en gratuit* /
///        *Restaurer* sont dans le widget
const Set<int> kAutoAdvanceSteps = <int>{3, 14};

/// Indices à validation gate — le bouton *Continuer* reste grisé tant
/// que l'input minimum n'est pas rempli.
///
/// - 1  : Goal (single-select)
/// - 2  : Pain points (≥ 1)
/// - 7  : Categories (≥ 1)
/// - 12 : Demo (≥ 3 kept)
const Set<int> kValidatedSteps = <int>{1, 2, 7, 12};

/// Validateur des steps onboarding — décide si l'user peut avancer
/// depuis l'index courant en regardant le state.
///
/// Source de vérité unique pour la NavBar (Continuer enabled/grisé).
abstract final class OnboardingStepValidator {
  /// Retourne `true` si le user peut avancer depuis [index].
  static bool canAdvance(int index, OnboardingState state) {
    return switch (index) {
      1 => state.goal != null,
      2 => state.painPoints.isNotEmpty,
      7 => state.contentCategories.isNotEmpty,
      12 => state.demoSwipedRightIndices.length >= 3,
      _ => true,
    };
  }

  /// Indique si l'écran a un message d'aide-validation à afficher.
  static bool requiresValidation(int index) => kValidatedSteps.contains(index);
}
