import 'package:beedle/domain/enum/engagement_message.enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'engagement_message.entity.freezed.dart';

/// Message d'engagement généré par le LLM à la digestion d'une card.
///
/// Pré-calculé et stocké dans un pool : picked plus tard par le scheduler
/// pour la Terminal Card (format long) ou pour une push (format short).
/// Voir `docs/tech-spec-engagement-layer-2026-04-15.md`.
@freezed
abstract class EngagementMessageEntity with _$EngagementMessageEntity {
  const factory EngagementMessageEntity({
    required String uuid,
    required String cardUuid,
    required String content,
    required EngagementMessageType type,
    required EngagementMessageFormat format,
    required int delayDays,
    required DateTime createdAt,
    DateTime? scheduledAt,
    DateTime? shownAt,
  }) = _EngagementMessageEntity;
}

extension EngagementMessageEntityX on EngagementMessageEntity {
  bool get isShown => shownAt != null;
  bool get isScheduled => scheduledAt != null;

  /// Un message est "éligible" (pickable) si sa fenêtre `delayDays` est
  /// atteinte et qu'il n'a pas déjà été montré.
  bool isEligibleAt(DateTime now, DateTime cardCreatedAt) {
    if (isShown) return false;
    final Duration age = now.difference(cardCreatedAt);
    return age.inDays >= delayDays;
  }
}
