import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_sample_card.entity.freezed.dart';
part 'onboarding_sample_card.entity.g.dart';

/// Échantillon de fiche pré-baké chargé depuis `assets/onboarding/samples/cards.json`.
///
/// Affiché tel quel dans le viral moment (écran 14) — pas un `CardEntity`
/// complet (pas d'embedding, status, uuid…), juste les champs nécessaires
/// au rendu d'une preview-card stylée onboarding.
@freezed
abstract class OnboardingSampleCard with _$OnboardingSampleCard {
  const factory OnboardingSampleCard({
    required String title,
    required String summary,
    required String actionLabel,
    required String intent,
    required List<String> tags,
  }) = _OnboardingSampleCard;

  factory OnboardingSampleCard.fromJson(Map<String, dynamic> json) =>
      _$OnboardingSampleCardFromJson(json);
}
