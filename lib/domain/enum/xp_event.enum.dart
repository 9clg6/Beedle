/// Événements qui accordent du XP.
enum XpEvent {
  cardImported(5),
  cardViewed(10),
  cardTested(50),
  streakBonus(30), // chaque jour de streak au-delà du 1er
  weeklyChallengeCompleted(100);

  const XpEvent(this.points);

  final int points;
}
