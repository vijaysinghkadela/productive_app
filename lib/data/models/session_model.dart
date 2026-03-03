/// Focus session data model
class SessionModel {
  // Score impact (+/-)

  const SessionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.startTime,
    required this.plannedDurationMinutes,
    this.label,
    this.endTime,
    this.actualDurationMinutes = 0,
    this.workMinutes = 25,
    this.breakMinutes = 5,
    this.completedPhases = 0,
    this.totalPhases = 4,
    this.distractionCount = 0,
    this.completed = false,
    this.ambientSound,
    this.productivityImpact,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        type: json['type'] as String,
        label: json['label'] as String?,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        plannedDurationMinutes: json['plannedDurationMinutes'] as int,
        actualDurationMinutes: json['actualDurationMinutes'] as int? ?? 0,
        workMinutes: json['workMinutes'] as int? ?? 25,
        breakMinutes: json['breakMinutes'] as int? ?? 5,
        completedPhases: json['completedPhases'] as int? ?? 0,
        totalPhases: json['totalPhases'] as int? ?? 4,
        distractionCount: json['distractionCount'] as int? ?? 0,
        completed: json['completed'] as bool? ?? false,
        ambientSound: json['ambientSound'] as String?,
        productivityImpact: (json['productivityImpact'] as num?)?.toDouble(),
      );
  final String id;
  final String userId;
  final String type; // Deep Work, Study, Creative, etc.
  final String? label; // Custom note
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedDurationMinutes;
  final int actualDurationMinutes;
  final int workMinutes;
  final int breakMinutes;
  final int completedPhases;
  final int totalPhases;
  final int distractionCount;
  final bool completed;
  final String? ambientSound;
  final double? productivityImpact;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'label': label,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'plannedDurationMinutes': plannedDurationMinutes,
        'actualDurationMinutes': actualDurationMinutes,
        'workMinutes': workMinutes,
        'breakMinutes': breakMinutes,
        'completedPhases': completedPhases,
        'totalPhases': totalPhases,
        'distractionCount': distractionCount,
        'completed': completed,
        'ambientSound': ambientSound,
        'productivityImpact': productivityImpact,
      };
}

/// Usage stat data model for per-app tracking
class UsageStatModel {
  const UsageStatModel({
    required this.date,
    required this.userId,
    this.appUsageMinutes = const {},
    this.totalScreenTimeMinutes = 0,
    this.socialMediaMinutes = 0,
    this.pickupCount = 0,
    this.focusSessionsCompleted = 0,
    this.goalsCompleted = 0,
    this.productivityScore = 50,
    this.firstUseTime,
    this.lastUseTime,
  });

  factory UsageStatModel.fromJson(Map<String, dynamic> json) => UsageStatModel(
        date: json['date'] as String,
        userId: json['userId'] as String,
        appUsageMinutes:
            Map<String, int>.from(json['appUsageMinutes'] as Map? ?? {}),
        totalScreenTimeMinutes: json['totalScreenTimeMinutes'] as int? ?? 0,
        socialMediaMinutes: json['socialMediaMinutes'] as int? ?? 0,
        pickupCount: json['pickupCount'] as int? ?? 0,
        focusSessionsCompleted: json['focusSessionsCompleted'] as int? ?? 0,
        goalsCompleted: json['goalsCompleted'] as int? ?? 0,
        productivityScore: json['productivityScore'] as int? ?? 50,
        firstUseTime: json['firstUseTime'] as String?,
        lastUseTime: json['lastUseTime'] as String?,
      );
  final String date; // yyyy-MM-dd
  final String userId;
  final Map<String, int> appUsageMinutes; // packageName → minutes
  final int totalScreenTimeMinutes;
  final int socialMediaMinutes;
  final int pickupCount;
  final int focusSessionsCompleted;
  final int goalsCompleted;
  final int productivityScore;
  final String? firstUseTime; // HH:mm
  final String? lastUseTime;

  Map<String, dynamic> toJson() => {
        'date': date,
        'userId': userId,
        'appUsageMinutes': appUsageMinutes,
        'totalScreenTimeMinutes': totalScreenTimeMinutes,
        'socialMediaMinutes': socialMediaMinutes,
        'pickupCount': pickupCount,
        'focusSessionsCompleted': focusSessionsCompleted,
        'goalsCompleted': goalsCompleted,
        'productivityScore': productivityScore,
        'firstUseTime': firstUseTime,
        'lastUseTime': lastUseTime,
      };
}

/// Goal data model
class GoalModel {
  const GoalModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.targetValue,
    required this.createdAt,
    this.category = 'General',
    this.currentProgress = 0,
    this.period = 'daily',
    this.streakDays = 0,
    this.isActive = true,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        category: json['category'] as String? ?? 'General',
        targetValue: json['targetValue'] as int,
        currentProgress: json['currentProgress'] as int? ?? 0,
        period: json['period'] as String? ?? 'daily',
        createdAt: DateTime.parse(json['createdAt'] as String),
        streakDays: json['streakDays'] as int? ?? 0,
        isActive: json['isActive'] as bool? ?? true,
      );
  final String id;
  final String userId;
  final String name;
  final String type; // screen_time, focus_time, social_media_free, etc.
  final String category;
  final int targetValue; // minutes or count
  final int currentProgress;
  final String period; // daily, weekly, monthly
  final DateTime createdAt;
  final int streakDays;
  final bool isActive;

  double get completionRate =>
      targetValue == 0 ? 0 : (currentProgress / targetValue).clamp(0.0, 1.0);

  bool get isCompleted => currentProgress >= targetValue;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'type': type,
        'category': category,
        'targetValue': targetValue,
        'currentProgress': currentProgress,
        'period': period,
        'createdAt': createdAt.toIso8601String(),
        'streakDays': streakDays,
        'isActive': isActive,
      };
}

/// Achievement data model
class AchievementModel {
  const AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    this.icon = '🏆',
    this.category = 'general',
    this.rarity = 'common',
    this.xpReward = 100,
    this.unlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
    this.targetValue = 1,
    this.currentValue = 0,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      AchievementModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String? ?? '🏆',
        category: json['category'] as String? ?? 'general',
        rarity: json['rarity'] as String? ?? 'common',
        xpReward: json['xpReward'] as int? ?? 100,
        unlocked: json['unlocked'] as bool? ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'] as String)
            : null,
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        targetValue: json['targetValue'] as int? ?? 1,
        currentValue: json['currentValue'] as int? ?? 0,
      );
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category; // focus_master, social_warrior, streak_champion, etc.
  final String rarity; // common, rare, epic, legendary
  final int xpReward;
  final bool unlocked;
  final DateTime? unlockedAt;
  final double progress; // 0.0-1.0
  final int targetValue;
  final int currentValue;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'category': category,
        'rarity': rarity,
        'xpReward': xpReward,
        'unlocked': unlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'progress': progress,
        'targetValue': targetValue,
        'currentValue': currentValue,
      };
}
