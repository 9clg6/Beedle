/// Type de notification locale.
enum NotificationType {
  /// Notif contenu-based générée depuis une fiche.
  teaser,

  /// Notif quotidienne de rappel d'import.
  capture
  ;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (NotificationType e) => e.name == value,
      orElse: () => NotificationType.teaser,
    );
  }
}
