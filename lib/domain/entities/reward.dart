class Reward {
  const Reward({
    this.totalXp = 0,
    this.level = 1,
    this.unlockedBadges = const [],
    this.unlockedThemes = const ['default'],
    this.focusSessionsCompleted = 0,
    this.habitsCompleted = 0,
    this.challengesCompleted = 0,
    this.goalsAchieved = 0,
    this.loginStreak = 0,
  });

  factory Reward.fromMap(Map<String, dynamic> m) => Reward(
        totalXp: m['totalXp'] as int? ?? 0,
        level: m['level'] as int? ?? 1,
        unlockedBadges: List<String>.from(m['unlockedBadges'] as List? ?? []),
        unlockedThemes:
            List<String>.from(m['unlockedThemes'] as List? ?? ['default']),
        focusSessionsCompleted: m['focusSessionsCompleted'] as int? ?? 0,
        habitsCompleted: m['habitsCompleted'] as int? ?? 0,
        challengesCompleted: m['challengesCompleted'] as int? ?? 0,
        goalsAchieved: m['goalsAchieved'] as int? ?? 0,
        loginStreak: m['loginStreak'] as int? ?? 0,
      );
  final int totalXp;
  final int level;
  final List<String> unlockedBadges;
  final List<String> unlockedThemes;
  final int focusSessionsCompleted;
  final int habitsCompleted;
  final int challengesCompleted;
  final int goalsAchieved;
  final int loginStreak;

  /// XP needed for next level (exponential curve)
  int get xpForNextLevel => (100 * level * 1.3).toInt();

  /// Progress to next level (0.0 - 1.0)
  double get levelProgress {
    final xpInCurrentLevel = totalXp - _xpForLevel(level);
    return (xpInCurrentLevel / xpForNextLevel).clamp(0.0, 1.0);
  }

  /// Total XP accumulated up to a given level
  int _xpForLevel(int lvl) {
    var total = 0;
    for (var i = 1; i < lvl; i++) {
      total += (100 * i * 1.3).toInt();
    }
    return total;
  }

  /// Level title based on current level
  String get levelTitle {
    if (level >= 50) return 'Focus God';
    if (level >= 40) return 'Legend';
    if (level >= 30) return 'Master';
    if (level >= 20) return 'Expert';
    if (level >= 15) return 'Veteran';
    if (level >= 10) return 'Adept';
    if (level >= 5) return 'Apprentice';
    return 'Novice';
  }

  Reward copyWith({
    int? totalXp,
    int? level,
    List<String>? unlockedBadges,
    List<String>? unlockedThemes,
    int? focusSessionsCompleted,
    int? habitsCompleted,
    int? challengesCompleted,
    int? goalsAchieved,
    int? loginStreak,
  }) =>
      Reward(
        totalXp: totalXp ?? this.totalXp,
        level: level ?? this.level,
        unlockedBadges: unlockedBadges ?? this.unlockedBadges,
        unlockedThemes: unlockedThemes ?? this.unlockedThemes,
        focusSessionsCompleted:
            focusSessionsCompleted ?? this.focusSessionsCompleted,
        habitsCompleted: habitsCompleted ?? this.habitsCompleted,
        challengesCompleted: challengesCompleted ?? this.challengesCompleted,
        goalsAchieved: goalsAchieved ?? this.goalsAchieved,
        loginStreak: loginStreak ?? this.loginStreak,
      );

  /// Add XP and auto-level if threshold exceeded
  Reward addXp(int xp) {
    final newXp = totalXp + xp;
    var newLevel = level;
    while (newXp >= _xpForLevel(newLevel) + (100 * newLevel * 1.3).toInt()) {
      newLevel++;
    }
    return copyWith(totalXp: newXp, level: newLevel);
  }

  Map<String, dynamic> toMap() => {
        'totalXp': totalXp,
        'level': level,
        'unlockedBadges': unlockedBadges,
        'unlockedThemes': unlockedThemes,
        'focusSessionsCompleted': focusSessionsCompleted,
        'habitsCompleted': habitsCompleted,
        'challengesCompleted': challengesCompleted,
        'goalsAchieved': goalsAchieved,
        'loginStreak': loginStreak,
      };
}
