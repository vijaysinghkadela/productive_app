class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetValue,
    this.currentValue = 0,
    this.unlocked = false,
    this.unlockedDate,
  });
  final String id;
  final String title;
  final String description;
  final String icon;
  final int targetValue;
  final int currentValue;
  final bool unlocked;
  final DateTime? unlockedDate;

  double get progress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  Achievement copyWith({
    int? currentValue,
    bool? unlocked,
    DateTime? unlockedDate,
  }) =>
      Achievement(
        id: id,
        title: title,
        description: description,
        icon: icon,
        targetValue: targetValue,
        currentValue: currentValue ?? this.currentValue,
        unlocked: unlocked ?? this.unlocked,
        unlockedDate: unlockedDate ?? this.unlockedDate,
      );
}

// Predefined achievements
List<Achievement> defaultAchievements = [
  const Achievement(
    id: 'streak_3',
    title: '3-Day Streak',
    description: 'Maintain a 3-day productivity streak',
    icon: '🔥',
    targetValue: 3,
  ),
  const Achievement(
    id: 'streak_7',
    title: 'Week Warrior',
    description: 'Maintain a 7-day productivity streak',
    icon: '⚡',
    targetValue: 7,
  ),
  const Achievement(
    id: 'streak_30',
    title: 'Monthly Master',
    description: 'Maintain a 30-day productivity streak',
    icon: '👑',
    targetValue: 30,
  ),
  const Achievement(
    id: 'focus_10h',
    title: 'Focused 10 Hours',
    description: 'Complete 10 hours of focus sessions',
    icon: '🎯',
    targetValue: 600, // minutes
  ),
  const Achievement(
    id: 'focus_50h',
    title: 'Focus Champion',
    description: 'Complete 50 hours of focus sessions',
    icon: '🏆',
    targetValue: 3000,
  ),
  const Achievement(
    id: 'social_free_day',
    title: 'Social Media Free Day',
    description: 'Go an entire day without social media',
    icon: '🧘',
    targetValue: 1,
  ),
  const Achievement(
    id: 'social_free_week',
    title: 'Digital Detox',
    description: 'Go 7 days with less than 30 min social media daily',
    icon: '🌟',
    targetValue: 7,
  ),
  const Achievement(
    id: 'goals_met_5',
    title: 'Goal Getter',
    description: 'Meet all your daily goals 5 days in a row',
    icon: '✅',
    targetValue: 5,
  ),
  const Achievement(
    id: 'sessions_25',
    title: 'Session Starter',
    description: 'Complete 25 focus sessions',
    icon: '⏱️',
    targetValue: 25,
  ),
  const Achievement(
    id: 'sessions_100',
    title: 'Century Club',
    description: 'Complete 100 focus sessions',
    icon: '💯',
    targetValue: 100,
  ),
  const Achievement(
    id: 'perfect_score',
    title: 'Perfect Day',
    description: 'Achieve a 100 productivity score',
    icon: '💎',
    targetValue: 1,
  ),
  const Achievement(
    id: 'early_bird',
    title: 'Early Bird',
    description: 'Start a focus session before 7 AM',
    icon: '🌅',
    targetValue: 1,
  ),
];
