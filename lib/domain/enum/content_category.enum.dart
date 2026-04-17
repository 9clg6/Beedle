/// Catégories de contenu (quiz d'OB + tagging auto).
enum ContentCategory {
  techAi,
  design,
  business,
  productivity,
  creative,
  other
  ;

  static ContentCategory fromString(String? value) {
    if (value == null) return ContentCategory.other;
    return ContentCategory.values.firstWhere(
      (ContentCategory e) => e.name == value,
      orElse: () => ContentCategory.other,
    );
  }
}
