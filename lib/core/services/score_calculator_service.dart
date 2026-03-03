/// Enterprise-grade productivity score calculator
///
/// Scoring algorithm (spec):
/// Start: 100 points
///
/// DEDUCTIONS:
/// - Social media over goal: -0.8/min (max -35)
/// - Screen time over goal: -0.3/min (max -20)
/// - Each "5 more minutes" override: -3 (max -15)
/// - Incomplete focus session: -5 each (max -15)
/// - No focus session by 11am: -5
/// - Habit not completed: -3 each (max -15)
/// - Poor sleep (≤5 hours): -10
///
/// ADDITIONS:
/// - Completed focus session: +8 each (max +40)
/// - Beat social media goal: +5/app (max +15)
/// - All daily goals met: +10
/// - All habits completed: +10
/// - Social media free day: +20
/// - Streak maintained: +1/day (max +15)
/// - Journal entry: +3
/// - Morning routine (no phone first hour): +5
///
/// Range: 0-100
library;

class ScoreCalculatorService {
  ScoreCalculatorService._();

  static int calculate({
    // Deduction inputs
    int socialMediaOverGoalMinutes = 0,
    int screenTimeOverGoalMinutes = 0,
    int overrideTaps = 0,
    int incompleteSessions = 0,
    bool noSessionBy11am = false,
    int habitsNotCompleted = 0,
    bool poorSleep = false,
    // Addition inputs
    int completedSessions = 0,
    int appsBeatGoal = 0,
    bool allGoalsMet = false,
    bool allHabitsCompleted = false,
    bool socialMediaFreeDay = false,
    int streakDays = 0,
    bool journalCompleted = false,
    bool morningRoutineCompleted = false,
  }) {
    double score = 100;

    // === DEDUCTIONS ===
    score -= (socialMediaOverGoalMinutes * 0.8).clamp(0, 35);
    score -= (screenTimeOverGoalMinutes * 0.3).clamp(0, 20);
    score -= (overrideTaps * 3).clamp(0, 15);
    score -= (incompleteSessions * 5).clamp(0, 15);
    if (noSessionBy11am) score -= 5;
    score -= (habitsNotCompleted * 3).clamp(0, 15);
    if (poorSleep) score -= 10;

    // === ADDITIONS ===
    score += (completedSessions * 8).clamp(0, 40);
    score += (appsBeatGoal * 5).clamp(0, 15);
    if (allGoalsMet) score += 10;
    if (allHabitsCompleted) score += 10;
    if (socialMediaFreeDay) score += 20;
    score += streakDays.clamp(0, 15).toDouble();
    if (journalCompleted) score += 3;
    if (morningRoutineCompleted) score += 5;

    return score.clamp(0, 100).round();
  }

  /// Get score breakdown as a map for analytics/debugging
  static Map<String, double> breakdown({
    int socialMediaOverGoalMinutes = 0,
    int screenTimeOverGoalMinutes = 0,
    int overrideTaps = 0,
    int incompleteSessions = 0,
    bool noSessionBy11am = false,
    int habitsNotCompleted = 0,
    bool poorSleep = false,
    int completedSessions = 0,
    int appsBeatGoal = 0,
    bool allGoalsMet = false,
    bool allHabitsCompleted = false,
    bool socialMediaFreeDay = false,
    int streakDays = 0,
    bool journalCompleted = false,
    bool morningRoutineCompleted = false,
  }) {
    return {
      'base': 100,
      'social_media_penalty': -(socialMediaOverGoalMinutes * 0.8).clamp(0, 35),
      'screen_time_penalty': -(screenTimeOverGoalMinutes * 0.3).clamp(0, 20),
      'override_penalty': -(overrideTaps * 3.0).clamp(0, 15),
      'incomplete_sessions_penalty': -(incompleteSessions * 5.0).clamp(0, 15),
      'no_morning_session_penalty': noSessionBy11am ? -5.0 : 0,
      'habits_penalty': -(habitsNotCompleted * 3.0).clamp(0, 15),
      'poor_sleep_penalty': poorSleep ? -10.0 : 0,
      'focus_sessions_bonus': (completedSessions * 8.0).clamp(0, 40),
      'apps_beat_goal_bonus': (appsBeatGoal * 5.0).clamp(0, 15),
      'all_goals_bonus': allGoalsMet ? 10.0 : 0,
      'all_habits_bonus': allHabitsCompleted ? 10.0 : 0,
      'social_free_bonus': socialMediaFreeDay ? 20.0 : 0,
      'streak_bonus': streakDays.clamp(0, 15).toDouble(),
      'journal_bonus': journalCompleted ? 3.0 : 0,
      'morning_routine_bonus': morningRoutineCompleted ? 5.0 : 0,
    };
  }

  /// Get color for score
  static String scoreTier(int score) {
    if (score >= 85) return 'excellent';
    if (score >= 70) return 'great';
    if (score >= 50) return 'good';
    if (score >= 30) return 'fair';
    return 'needs_improvement';
  }
}
