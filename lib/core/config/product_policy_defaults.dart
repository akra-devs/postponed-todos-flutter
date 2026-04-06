class ProductPolicyDefaults {
  const ProductPolicyDefaults._();

  static const Duration firstSnoozeCooldown = Duration(hours: 24);
  static const Duration secondConsecutiveSnoozeCooldown = Duration(hours: 72);
  static const Duration repeatedSnoozeCooldown = Duration(days: 7);

  static const int noActionSoftPenaltyThreshold = 2;
  static const int noActionStrongPenaltyThreshold = 3;
  static const int holdingBoxSuggestionThreshold = 4;
  static const Duration holdingBoxRevisitSuggestion = Duration(days: 14);
  static const int homeDefaultCards = 4;

  static const Duration completionRewardThrottleCooldown = Duration(
    minutes: 45,
  );

  static Duration cooldownForSnoozeCount(int consecutiveSnoozeCount) {
    if (consecutiveSnoozeCount <= 1) return firstSnoozeCooldown;
    if (consecutiveSnoozeCount == 2) return secondConsecutiveSnoozeCooldown;
    return repeatedSnoozeCooldown;
  }
}
