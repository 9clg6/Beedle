/// Tier d'abonnement Beedle.
enum SubscriptionTier {
  free,
  pro;

  bool get isPro => this == SubscriptionTier.pro;

  static SubscriptionTier fromString(String? value) {
    if (value == null) return SubscriptionTier.free;
    return SubscriptionTier.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => SubscriptionTier.free,
    );
  }
}
