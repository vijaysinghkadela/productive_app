class Habit {
  final String id;
  final String name;
  final String icon; // emoji
  final HabitFrequency frequency;
  final List<int> targetDays; // 1=Mon..7=Sun, empty = every day
  final String? reminderTime; // HH:mm
  final String category;
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final List<String> completedDates; // yyyy-MM-dd
  final DateTime createdAt;
  final bool isActive;

  const Habit({
    required this.id,
    required this.name,
    this.icon = '🎯',
    this.frequency = HabitFrequency.daily,
    this.targetDays = const [],
    this.reminderTime,
    this.category = 'General',
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    this.completedDates = const [],
    required this.createdAt,
    this.isActive = true,
  });

  bool get isCompletedToday {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return completedDates.contains(todayStr);
  }

  double get completionRate {
    if (totalCompletions == 0) return 0;
    final daysSinceCreation =
        DateTime.now().difference(createdAt).inDays.clamp(1, 9999);
    return (totalCompletions / daysSinceCreation).clamp(0.0, 1.0);
  }

  Habit copyWith({
    String? name,
    String? icon,
    HabitFrequency? frequency,
    List<int>? targetDays,
    String? reminderTime,
    String? category,
    int? currentStreak,
    int? longestStreak,
    int? totalCompletions,
    List<String>? completedDates,
    bool? isActive,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      reminderTime: reminderTime ?? this.reminderTime,
      category: category ?? this.category,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon': icon,
        'frequency': frequency.name,
        'targetDays': targetDays,
        'reminderTime': reminderTime,
        'category': category,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalCompletions': totalCompletions,
        'completedDates': completedDates,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
      };

  factory Habit.fromMap(Map<String, dynamic> m) => Habit(
        id: m['id'] as String,
        name: m['name'] as String,
        icon: m['icon'] as String? ?? '🎯',
        frequency: HabitFrequency.values.firstWhere(
            (e) => e.name == m['frequency'],
            orElse: () => HabitFrequency.daily),
        targetDays: List<int>.from(m['targetDays'] as List? ?? []),
        reminderTime: m['reminderTime'] as String?,
        category: m['category'] as String? ?? 'General',
        currentStreak: m['currentStreak'] as int? ?? 0,
        longestStreak: m['longestStreak'] as int? ?? 0,
        totalCompletions: m['totalCompletions'] as int? ?? 0,
        completedDates: List<String>.from(m['completedDates'] as List? ?? []),
        createdAt: DateTime.parse(m['createdAt'] as String),
        isActive: m['isActive'] as bool? ?? true,
      );
}

enum HabitFrequency { daily, weekdays, weekends, custom }
