/// Niveaux de progression (XP-based) — pure vanity, pas de feature gating.
enum BeedleLevel {
  curator(0, 'Curator'),
  explorer(200, 'Explorer'),
  mapmaker(800, 'Mapmaker'),
  sensei(2500, 'Sensei'),
  legend(6000, 'Legend')
  ;

  const BeedleLevel(this.thresholdXp, this.title);

  final int thresholdXp;
  final String title;

  static BeedleLevel fromXp(int xp) {
    BeedleLevel current = BeedleLevel.curator;
    for (final BeedleLevel level in BeedleLevel.values) {
      if (xp >= level.thresholdXp) current = level;
    }
    return current;
  }

  BeedleLevel? get next {
    final int idx = BeedleLevel.values.indexOf(this);
    if (idx + 1 >= BeedleLevel.values.length) return null;
    return BeedleLevel.values[idx + 1];
  }

  /// Progrès (0.0–1.0) vers le prochain niveau à partir du XP fourni.
  double progressToNext(int xp) {
    final BeedleLevel? n = next;
    if (n == null) return 1;
    final int span = n.thresholdXp - thresholdXp;
    if (span == 0) return 1;
    return ((xp - thresholdXp) / span).clamp(0.0, 1.0);
  }
}
