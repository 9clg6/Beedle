/// Types de messages d'engagement générés par le LLM.
///
/// - [reminder] — "Teste le prompt de Sthiven aujourd'hui"
/// - [invite]   — "5 min pour revoir ta card sur prompt caching ?"
/// - [observation] — "3 cards sur Claude cette semaine"
/// - [connection] — "Ce que dit Sthiven complète la card de Guillaume"
/// - [reflection] — "Qu'as-tu gardé de la card d'hier soir ?"
enum EngagementMessageType {
  reminder,
  invite,
  observation,
  connection,
  reflection
  ;

  static EngagementMessageType fromString(String? value) {
    return EngagementMessageType.values.firstWhere(
      (EngagementMessageType e) => e.name == value,
      orElse: () => EngagementMessageType.observation,
    );
  }
}

/// Format du message — détermine la surface cible.
///
/// - [short] ≤ 40 chars → push notification OS
/// - [long]  ≤ 120 chars → terminal card sur Home
enum EngagementMessageFormat {
  short,
  long
  ;

  static EngagementMessageFormat fromString(String? value) {
    return EngagementMessageFormat.values.firstWhere(
      (EngagementMessageFormat e) => e.name == value,
      orElse: () => EngagementMessageFormat.long,
    );
  }
}
