/// App-wide constants and enums for FocusGuard Pro
///
/// Re-exports the original constants.dart for backward compatibility
/// and adds enterprise-grade constants.
library;

export '../constants.dart';
export 'api_constants.dart';
export 'route_constants.dart';
export 'asset_constants.dart';

/// Subscription tiers with feature gates
enum FeatureTier { free, basic, pro, elite }

/// Focus session types
const List<String> allSessionTypes = [
  'Deep Work',
  'Study',
  'Creative',
  'Reading',
  'Exercise',
  'Meditation',
  'Coding',
  'Writing',
];

/// Achievement rarity levels
enum AchievementRarity { common, rare, epic, legendary }

/// XP rewards
class XpRewards {
  XpRewards._();
  static const int focusSession = 50;
  static const int habitComplete = 20;
  static const int beatDailyGoal = 30;
  static const int dailyLogin = 10;
  static const int achievementCommon = 100;
  static const int achievementRare = 250;
  static const int achievementEpic = 500;
  static const int achievementLegendary = 1000;
}

/// Social media detection — Android package names
const Map<String, String> socialMediaPackagesAndroid = {
  'com.instagram.android': 'Instagram',
  'com.zhiliaoapp.musically': 'TikTok',
  'com.google.android.youtube': 'YouTube',
  'com.twitter.android': 'Twitter/X',
  'com.facebook.katana': 'Facebook',
  'com.snapchat.android': 'Snapchat',
  'com.pinterest': 'Pinterest',
  'com.reddit.frontpage': 'Reddit',
  'com.linkedin.android': 'LinkedIn',
  'com.tumblr': 'Tumblr',
  'AlexisBarreyat.BeReal': 'BeReal',
  'tv.twitch.android.app': 'Twitch',
  'com.discord': 'Discord',
};

/// Social media detection — iOS bundle IDs
const Map<String, String> socialMediaBundlesIos = {
  'com.burbn.instagram': 'Instagram',
  'com.zhiliaoapp.musically': 'TikTok',
  'com.google.ios.youtube': 'YouTube',
  'com.atebits.Tweetie2': 'Twitter/X',
  'com.facebook.Facebook': 'Facebook',
  'com.toyopagroup.picaboo': 'Snapchat',
  'com.pinterest': 'Pinterest',
  'com.reddit.Reddit': 'Reddit',
  'com.linkedin.LinkedIn': 'LinkedIn',
  'com.tumblr.tumblr': 'Tumblr',
  'AlexisBarreyat.BeReal': 'BeReal',
  'tv.twitch': 'Twitch',
  'com.hammerandchisel.discord': 'Discord',
};

/// App categories for auto-detection
enum AppCategory {
  socialMedia,
  entertainment,
  games,
  shopping,
  news,
  dating,
  finance,
  productivity,
  communication,
  health,
  education,
  other,
}

/// Notification channels
class NotificationChannels {
  NotificationChannels._();
  static const String blocking = 'blocking_alerts';
  static const String goals = 'goal_updates';
  static const String achievements = 'achievement_unlocks';
  static const String social = 'social_updates';
  static const String aiCoach = 'ai_coaching';
  static const String system = 'system_notifications';
  static const String focus = 'focus_session';
  static const String wellbeing = 'wellbeing_reminders';
}
