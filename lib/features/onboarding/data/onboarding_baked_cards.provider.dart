import 'package:beedle/core/providers/data_providers.dart';
import 'package:beedle/features/onboarding/data/onboarding_baked_cards.repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider du repository qui charge + persiste les fiches packagées
/// dans `assets/onboarding/baked/cards/`. Utilisé par :
/// - L'écran 14 (preview stack visuelle, sans embedding)
/// - `OnboardingViewModel.finishOnboarding()` (persistance + embedding)
final Provider<OnboardingBakedCardsRepository>
onboardingBakedCardsRepositoryProvider =
    Provider<OnboardingBakedCardsRepository>((Ref ref) {
      return OnboardingBakedCardsRepository(
        cardRepository: ref.watch(cardRepositoryProvider),
        embeddingsRepository: ref.watch(embeddingsRepositoryProvider),
      );
    });
