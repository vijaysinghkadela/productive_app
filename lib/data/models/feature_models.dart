/// Habit data model
class HabitModel {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final String category;
  final String frequency; // daily, weekdays, weekends, custom
  final List<int> targetDays; // 1=Mon, 7=Sun
  final String? reminderTime; // HH:mm
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final List<String> completedDates; // yyyy-MM-dd
  final DateTime createdAt;
  final bool isActive;
  final String? stackedWith; // habit id to chain with

  const HabitModel({
    required this.id,
    required this.userId,
    required this.name,
    this.icon = '🎯',
    this.category = 'General',
    this.frequency = 'daily',
    this.targetDays = const [1, 2, 3, 4, 5, 6, 7],
    this.reminderTime,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    this.completedDates = const [],
    required this.createdAt,
    this.isActive = true,
    this.stackedWith,
  });

  double get completionRate {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    if (daysSinceCreation <= 0) return 0;
    return (totalCompletions / daysSinceCreation).clamp(0.0, 1.0);
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) => HabitModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String? ?? '🎯',
        category: json['category'] as String? ?? 'General',
        frequency: json['frequency'] as String? ?? 'daily',
        targetDays: List<int>.from(json['targetDays'] ?? [1, 2, 3, 4, 5, 6, 7]),
        reminderTime: json['reminderTime'] as String?,
        currentStreak: json['currentStreak'] as int? ?? 0,
        longestStreak: json['longestStreak'] as int? ?? 0,
        totalCompletions: json['totalCompletions'] as int? ?? 0,
        completedDates: List<String>.from(json['completedDates'] ?? []),
        createdAt: DateTime.parse(json['createdAt'] as String),
        isActive: json['isActive'] as bool? ?? true,
        stackedWith: json['stackedWith'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'icon': icon,
        'category': category,
        'frequency': frequency,
        'targetDays': targetDays,
        'reminderTime': reminderTime,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalCompletions': totalCompletions,
        'completedDates': completedDates,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
        'stackedWith': stackedWith,
      };
}

/// Challenge data model
class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String type; // community, personal, friend
  final String category;
  final int durationDays;
  final int participantCount;
  final int currentDay;
  final double progress; // 0.0-1.0
  final int xpReward;
  final String? badgeReward;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isCompleted;
  final Map<String, dynamic> rules;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    this.type = 'community',
    this.category = 'general',
    this.durationDays = 7,
    this.participantCount = 0,
    this.currentDay = 0,
    this.progress = 0.0,
    this.xpReward = 500,
    this.badgeReward,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.isCompleted = false,
    this.rules = const {},
  });

  int get daysRemaining {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff.clamp(0, durationDays);
  }

  factory ChallengeModel.fromJson(Map<String, dynamic> json) => ChallengeModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        type: json['type'] as String? ?? 'community',
        category: json['category'] as String? ?? 'general',
        durationDays: json['durationDays'] as int? ?? 7,
        participantCount: json['participantCount'] as int? ?? 0,
        currentDay: json['currentDay'] as int? ?? 0,
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        xpReward: json['xpReward'] as int? ?? 500,
        badgeReward: json['badgeReward'] as String?,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        isActive: json['isActive'] as bool? ?? true,
        isCompleted: json['isCompleted'] as bool? ?? false,
        rules: Map<String, dynamic>.from(json['rules'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type,
        'category': category,
        'durationDays': durationDays,
        'participantCount': participantCount,
        'currentDay': currentDay,
        'progress': progress,
        'xpReward': xpReward,
        'badgeReward': badgeReward,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isActive': isActive,
        'isCompleted': isCompleted,
        'rules': rules,
      };
}

/// Journal entry data model
class JournalModel {
  final String id;
  final String userId;
  final DateTime date;
  final String content;
  final int mood; // 1-5
  final int focusRating; // 1-10
  final List<String> gratitude;
  final List<String> tags;
  final bool isPinned;
  final int? productivityScore;
  final String? topDistraction;

  const JournalModel({
    required this.id,
    required this.userId,
    required this.date,
    this.content = '',
    this.mood = 3,
    this.focusRating = 5,
    this.gratitude = const [],
    this.tags = const [],
    this.isPinned = false,
    this.productivityScore,
    this.topDistraction,
  });

  String get moodEmoji {
    switch (mood) {
      case 1:
        return '😞';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😊';
      case 5:
        return '🤩';
      default:
        return '🙂';
    }
  }

  factory JournalModel.fromJson(Map<String, dynamic> json) => JournalModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        date: DateTime.parse(json['date'] as String),
        content: json['content'] as String? ?? '',
        mood: json['mood'] as int? ?? 3,
        focusRating: json['focusRating'] as int? ?? 5,
        gratitude: List<String>.from(json['gratitude'] ?? []),
        tags: List<String>.from(json['tags'] ?? []),
        isPinned: json['isPinned'] as bool? ?? false,
        productivityScore: json['productivityScore'] as int?,
        topDistraction: json['topDistraction'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'date': date.toIso8601String(),
        'content': content,
        'mood': mood,
        'focusRating': focusRating,
        'gratitude': gratitude,
        'tags': tags,
        'isPinned': isPinned,
        'productivityScore': productivityScore,
        'topDistraction': topDistraction,
      };
}

/// AI Coaching message model
class AiCoachingModel {
  final String id;
  final String userId;
  final String role; // user, assistant
  final String content;
  final DateTime timestamp;
  final String? insightType; // pattern, review, challenge, wellness

  const AiCoachingModel({
    required this.id,
    required this.userId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.insightType,
  });

  factory AiCoachingModel.fromJson(Map<String, dynamic> json) =>
      AiCoachingModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        insightType: json['insightType'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'insightType': insightType,
      };
}

/// Leaderboard entry model
class LeaderboardModel {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final int rank;
  final int previousRank;
  final int score;
  final String category; // productivity, focus, streak, etc.
  final String period; // today, week, month, allTime
  final String? country;
  final String? levelBadge;

  const LeaderboardModel({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.rank,
    this.previousRank = 0,
    required this.score,
    this.category = 'productivity',
    this.period = 'week',
    this.country,
    this.levelBadge,
  });

  int get rankChange => previousRank == 0 ? 0 : previousRank - rank;

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) =>
      LeaderboardModel(
        userId: json['userId'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
        rank: json['rank'] as int,
        previousRank: json['previousRank'] as int? ?? 0,
        score: json['score'] as int,
        category: json['category'] as String? ?? 'productivity',
        period: json['period'] as String? ?? 'week',
        country: json['country'] as String?,
        levelBadge: json['levelBadge'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'avatarUrl': avatarUrl,
        'rank': rank,
        'previousRank': previousRank,
        'score': score,
        'category': category,
        'period': period,
        'country': country,
        'levelBadge': levelBadge,
      };
}

/// Subscription data model
class SubscriptionModel {
  final String userId;
  final String tier; // free, basic, pro, elite
  final String? productId;
  final DateTime? purchaseDate;
  final DateTime? expirationDate;
  final bool isTrialActive;
  final bool willRenew;
  final String store; // appStore, playStore

  const SubscriptionModel({
    required this.userId,
    this.tier = 'free',
    this.productId,
    this.purchaseDate,
    this.expirationDate,
    this.isTrialActive = false,
    this.willRenew = false,
    this.store = 'playStore',
  });

  bool get isActive {
    if (tier == 'free') return true;
    if (expirationDate == null) return false;
    return expirationDate!.isAfter(DateTime.now());
  }

  bool get isPro => tier == 'pro' || tier == 'elite';
  bool get isElite => tier == 'elite';

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionModel(
        userId: json['userId'] as String,
        tier: json['tier'] as String? ?? 'free',
        productId: json['productId'] as String?,
        purchaseDate: json['purchaseDate'] != null
            ? DateTime.parse(json['purchaseDate'] as String)
            : null,
        expirationDate: json['expirationDate'] != null
            ? DateTime.parse(json['expirationDate'] as String)
            : null,
        isTrialActive: json['isTrialActive'] as bool? ?? false,
        willRenew: json['willRenew'] as bool? ?? false,
        store: json['store'] as String? ?? 'playStore',
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'tier': tier,
        'productId': productId,
        'purchaseDate': purchaseDate?.toIso8601String(),
        'expirationDate': expirationDate?.toIso8601String(),
        'isTrialActive': isTrialActive,
        'willRenew': willRenew,
        'store': store,
      };
}

/// Notification data model
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // blocking, goal, achievement, social, ai_coach, system
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? actionData;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: json['type'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
        actionData: json['actionData'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'actionData': actionData,
      };
}

/// Reward/XP system model
class RewardModel {
  final String userId;
  final int totalXp;
  final int level;
  final List<String> unlockedBadges;
  final List<String> unlockedThemes;
  final int focusSessionsCompleted;
  final int habitsCompleted;
  final int challengesCompleted;
  final int goalsAchieved;
  final int loginStreak;

  const RewardModel({
    required this.userId,
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

  int get xpForNextLevel => (100 * level * 1.3).toInt();

  double get levelProgress {
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += (100 * i * 1.3).toInt();
    }
    final xpInLevel = totalXp - total;
    return (xpInLevel / xpForNextLevel).clamp(0.0, 1.0);
  }

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

  factory RewardModel.fromJson(Map<String, dynamic> json) => RewardModel(
        userId: json['userId'] as String,
        totalXp: json['totalXp'] as int? ?? 0,
        level: json['level'] as int? ?? 1,
        unlockedBadges: List<String>.from(json['unlockedBadges'] ?? []),
        unlockedThemes:
            List<String>.from(json['unlockedThemes'] ?? ['default']),
        focusSessionsCompleted: json['focusSessionsCompleted'] as int? ?? 0,
        habitsCompleted: json['habitsCompleted'] as int? ?? 0,
        challengesCompleted: json['challengesCompleted'] as int? ?? 0,
        goalsAchieved: json['goalsAchieved'] as int? ?? 0,
        loginStreak: json['loginStreak'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
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

/// App restriction model for app blocker
class AppRestrictionModel {
  final String packageName;
  final String appName;
  final String? category;
  final bool isBlocked;
  final int? dailyLimitMinutes;
  final int usedTodayMinutes;
  final List<String>? blockedTimeRanges; // "09:00-18:00"
  final List<int>? blockedDays; // 1=Mon
  final int gracePeriodMinutes;

  const AppRestrictionModel({
    required this.packageName,
    required this.appName,
    this.category,
    this.isBlocked = false,
    this.dailyLimitMinutes,
    this.usedTodayMinutes = 0,
    this.blockedTimeRanges,
    this.blockedDays,
    this.gracePeriodMinutes = 5,
  });

  bool get isOverLimit =>
      dailyLimitMinutes != null && usedTodayMinutes >= dailyLimitMinutes!;

  int get remainingMinutes => dailyLimitMinutes != null
      ? (dailyLimitMinutes! - usedTodayMinutes).clamp(0, 999)
      : 999;

  factory AppRestrictionModel.fromJson(Map<String, dynamic> json) =>
      AppRestrictionModel(
        packageName: json['packageName'] as String,
        appName: json['appName'] as String,
        category: json['category'] as String?,
        isBlocked: json['isBlocked'] as bool? ?? false,
        dailyLimitMinutes: json['dailyLimitMinutes'] as int?,
        usedTodayMinutes: json['usedTodayMinutes'] as int? ?? 0,
        blockedTimeRanges: json['blockedTimeRanges'] != null
            ? List<String>.from(json['blockedTimeRanges'])
            : null,
        blockedDays: json['blockedDays'] != null
            ? List<int>.from(json['blockedDays'])
            : null,
        gracePeriodMinutes: json['gracePeriodMinutes'] as int? ?? 5,
      );

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
        'category': category,
        'isBlocked': isBlocked,
        'dailyLimitMinutes': dailyLimitMinutes,
        'usedTodayMinutes': usedTodayMinutes,
        'blockedTimeRanges': blockedTimeRanges,
        'blockedDays': blockedDays,
        'gracePeriodMinutes': gracePeriodMinutes,
      };
}

/// Focus mode data model
class FocusModeModel {
  final String id;
  final String name;
  final String icon;
  final List<String> blockedApps;
  final List<String> allowedApps;
  final String notificationFilter; // none, calls_only, all
  final String? soundProfile;
  final int? durationMinutes;
  final bool isBuiltIn;
  final bool isActive;
  final Map<String, dynamic>? schedule;

  const FocusModeModel({
    required this.id,
    required this.name,
    this.icon = '🎯',
    this.blockedApps = const [],
    this.allowedApps = const [],
    this.notificationFilter = 'none',
    this.soundProfile,
    this.durationMinutes,
    this.isBuiltIn = false,
    this.isActive = false,
    this.schedule,
  });

  factory FocusModeModel.fromJson(Map<String, dynamic> json) => FocusModeModel(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String? ?? '🎯',
        blockedApps: List<String>.from(json['blockedApps'] ?? []),
        allowedApps: List<String>.from(json['allowedApps'] ?? []),
        notificationFilter: json['notificationFilter'] as String? ?? 'none',
        soundProfile: json['soundProfile'] as String?,
        durationMinutes: json['durationMinutes'] as int?,
        isBuiltIn: json['isBuiltIn'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? false,
        schedule: json['schedule'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'blockedApps': blockedApps,
        'allowedApps': allowedApps,
        'notificationFilter': notificationFilter,
        'soundProfile': soundProfile,
        'durationMinutes': durationMinutes,
        'isBuiltIn': isBuiltIn,
        'isActive': isActive,
        'schedule': schedule,
      };
}

/// Report data model
class ReportModel {
  final String id;
  final String userId;
  final String type; // weekly, monthly
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime generatedAt;
  final int averageScore;
  final int totalFocusMinutes;
  final int totalSocialMediaMinutes;
  final int habitsCompletedCount;
  final int goalsMetCount;
  final int achievementsUnlocked;
  final Map<String, int> appUsageSummary;
  final List<String> insights;
  final List<String> recommendations;

  const ReportModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.generatedAt,
    this.averageScore = 0,
    this.totalFocusMinutes = 0,
    this.totalSocialMediaMinutes = 0,
    this.habitsCompletedCount = 0,
    this.goalsMetCount = 0,
    this.achievementsUnlocked = 0,
    this.appUsageSummary = const {},
    this.insights = const [],
    this.recommendations = const [],
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        type: json['type'] as String,
        periodStart: DateTime.parse(json['periodStart'] as String),
        periodEnd: DateTime.parse(json['periodEnd'] as String),
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        averageScore: json['averageScore'] as int? ?? 0,
        totalFocusMinutes: json['totalFocusMinutes'] as int? ?? 0,
        totalSocialMediaMinutes: json['totalSocialMediaMinutes'] as int? ?? 0,
        habitsCompletedCount: json['habitsCompletedCount'] as int? ?? 0,
        goalsMetCount: json['goalsMetCount'] as int? ?? 0,
        achievementsUnlocked: json['achievementsUnlocked'] as int? ?? 0,
        appUsageSummary: Map<String, int>.from(json['appUsageSummary'] ?? {}),
        insights: List<String>.from(json['insights'] ?? []),
        recommendations: List<String>.from(json['recommendations'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
        'generatedAt': generatedAt.toIso8601String(),
        'averageScore': averageScore,
        'totalFocusMinutes': totalFocusMinutes,
        'totalSocialMediaMinutes': totalSocialMediaMinutes,
        'habitsCompletedCount': habitsCompletedCount,
        'goalsMetCount': goalsMetCount,
        'achievementsUnlocked': achievementsUnlocked,
        'appUsageSummary': appUsageSummary,
        'insights': insights,
        'recommendations': recommendations,
      };
}

/// Accountability pair model
class AccountabilityModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  final bool isActive;
  final int messageCount;
  final int cheersCount;
  final int nudgesCount;
  final int daysPartnered;

  const AccountabilityModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    this.isActive = true,
    this.messageCount = 0,
    this.cheersCount = 0,
    this.nudgesCount = 0,
    this.daysPartnered = 0,
  });

  factory AccountabilityModel.fromJson(Map<String, dynamic> json) =>
      AccountabilityModel(
        id: json['id'] as String,
        user1Id: json['user1Id'] as String,
        user2Id: json['user2Id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        isActive: json['isActive'] as bool? ?? true,
        messageCount: json['messageCount'] as int? ?? 0,
        cheersCount: json['cheersCount'] as int? ?? 0,
        nudgesCount: json['nudgesCount'] as int? ?? 0,
        daysPartnered: json['daysPartnered'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user1Id': user1Id,
        'user2Id': user2Id,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
        'messageCount': messageCount,
        'cheersCount': cheersCount,
        'nudgesCount': nudgesCount,
        'daysPartnered': daysPartnered,
      };
}
