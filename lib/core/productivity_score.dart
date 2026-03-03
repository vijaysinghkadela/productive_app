/// Calculate daily productivity score (0-100)
///
/// Algorithm:
/// - Start at 100
/// - Deduct 0.5 points for each minute over goal on blocked/social apps
/// - Add 10 points for each completed focus session (max 50)
/// - Add 5 points for each daily goal met (max 25)
/// - Add 2 points per streak day (max 20)
/// - Bonus: Social media free day = +20 points
/// - Clamp result to 0-100
class ProductivityScoreCalculator {
  /// [overGoalMinutes] — total minutes spent beyond goal on social/blocked apps
  /// [completedSessions] — number of completed focus sessions today
  /// [goalsMet] — number of daily app goals met today
  /// [streakDays] — current consecutive days streak
  /// [socialMediaFreeDay] — true if zero social media usage today
  static int calculate({
    required int overGoalMinutes,
    required int completedSessions,
    required int goalsMet,
    required int streakDays,
    required bool socialMediaFreeDay,
  }) {
    double score = 100;

    // Deduct for going over goals
    score -= overGoalMinutes * 0.5;

    // Add for completed focus sessions (max 50 points)
    score += (completedSessions * 10).clamp(0, 50);

    // Add for goals met (max 25 points)
    score += (goalsMet * 5).clamp(0, 25);

    // Streak bonus (max 20 points)
    score += (streakDays * 2).clamp(0, 20);

    // Social media free day bonus
    if (socialMediaFreeDay) {
      score += 20;
    }

    return score.clamp(0, 100).round();
  }
}
