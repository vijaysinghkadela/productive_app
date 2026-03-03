/// API Constants for FocusGuard Pro
class ApiConstants {
  ApiConstants._();

  // Firebase
  static const String usersCollection = 'users';
  static const String sessionsCollection = 'sessions';
  static const String dailyStatsCollection = 'daily_stats';
  static const String goalsCollection = 'goals';
  static const String habitsCollection = 'habits';
  static const String challengesCollection = 'challenges';
  static const String journalCollection = 'journal_entries';
  static const String achievementsCollection = 'achievements';
  static const String leaderboardCollection = 'leaderboard';
  static const String rewardsCollection = 'rewards';
  static const String accountabilityCollection = 'accountability_pairs';
  static const String notificationsCollection = 'notifications';
  static const String reportsCollection = 'reports';
  static const String focusModesCollection = 'focus_modes';

  // OpenAI
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String openAiChatEndpoint = '/chat/completions';
  static const String openAiModel = 'gpt-4o';
  static const int openAiMaxTokens = 500;
  static const double openAiTemperature = 0.7;
  static const String aiCoachSystemPrompt =
      'You are Alex, a friendly and motivating productivity coach. '
      'You have access to the user\'s FocusGuard analytics. '
      'Respond concisely, warmly, and with specific actionable advice based on their data. '
      'Never be judgmental. Always encourage.';

  // RevenueCat
  static const String revenueCatApiKeyAndroid = 'rc_android_key';
  static const String revenueCatApiKeyIos = 'rc_ios_key';

  // Firebase Functions
  static const String getAiCoachingFunction = 'getAICoaching';
  static const String generateReportFunction = 'generateReport';

  // Rate Limits
  static const int aiCoachingFreeLimit = 0;
  static const int aiCoachingProLimit = 10;
  static const int aiCoachingEliteLimit = 999;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);
}
