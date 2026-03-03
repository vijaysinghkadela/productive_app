import '../../core/errors/failure.dart';
import '../../data/models/user_model.dart';
import '../../data/models/session_model.dart';
import '../../data/models/feature_models.dart';

/// Abstract repository interfaces for Clean Architecture.
/// Implementations in data/repositories/ depend on datasources.

/// User repository
abstract class UserRepository {
  Future<Result<UserModel>> getCurrentUser();
  Future<Result<UserModel>> getUserById(String uid);
  Future<Result<void>> updateUser(UserModel user);
  Future<Result<void>> deleteUser(String uid);
  Future<Result<UserModel>> signIn(String email, String password);
  Future<Result<UserModel>> signUp(
      String email, String password, String displayName);
  Future<Result<void>> signOut();
  Future<Result<void>> resetPassword(String email);
  Future<Result<UserModel>> signInWithGoogle();
  Future<Result<UserModel>> signInWithApple();
}

/// Session repository
abstract class SessionRepository {
  Future<Result<SessionModel>> startSession(SessionModel session);
  Future<Result<SessionModel>> endSession(String id, {required bool completed});
  Future<Result<List<SessionModel>>> getSessionHistory({int limit = 30});
  Future<Result<Map<String, dynamic>>> getSessionStats(String period);
}

/// Usage stats repository
abstract class UsageRepository {
  Future<Result<UsageStatModel>> getDailyUsage(String date);
  Future<Result<List<UsageStatModel>>> getWeeklyUsage();
  Future<Result<List<UsageStatModel>>> getMonthlyUsage();
  Future<Result<Map<String, int>>> getAppUsage(
      String packageName, String period);
}

/// Goal repository
abstract class GoalRepository {
  Future<Result<List<GoalModel>>> getGoals({bool activeOnly = true});
  Future<Result<GoalModel>> createGoal(GoalModel goal);
  Future<Result<void>> updateGoalProgress(String id, int progress);
  Future<Result<void>> deleteGoal(String id);
}

/// Achievement repository
abstract class AchievementRepository {
  Future<Result<List<AchievementModel>>> getAchievements();
  Future<Result<AchievementModel>> unlockAchievement(String id);
  Future<Result<List<AchievementModel>>> getUnlockedAchievements();
}

/// Habit repository
abstract class HabitRepository {
  Future<Result<List<HabitModel>>> getHabits({bool activeOnly = true});
  Future<Result<HabitModel>> createHabit(HabitModel habit);
  Future<Result<void>> toggleHabitCompletion(String id, String date);
  Future<Result<void>> deleteHabit(String id);
  Future<Result<Map<String, dynamic>>> getHabitStreaks(String id);
}

/// Challenge repository
abstract class ChallengeRepository {
  Future<Result<List<ChallengeModel>>> getActiveChallenges();
  Future<Result<List<ChallengeModel>>> getAvailableChallenges();
  Future<Result<void>> joinChallenge(String id);
  Future<Result<void>> updateChallengeProgress(String id, double progress);
}

/// Journal repository
abstract class JournalRepository {
  Future<Result<List<JournalModel>>> getEntries({int limit = 30});
  Future<Result<JournalModel>> createEntry(JournalModel entry);
  Future<Result<void>> updateEntry(JournalModel entry);
  Future<Result<void>> deleteEntry(String id);
  Future<Result<List<JournalModel>>> searchEntries(String query);
}

/// AI Coaching repository
abstract class AiCoachingRepository {
  Future<Result<String>> getAiResponse(
      String message, Map<String, dynamic> context);
  Future<Result<List<AiCoachingModel>>> getConversationHistory(
      {int limit = 30});
  Future<Result<String>> getDailyInsight(Map<String, dynamic> stats);
}

/// Leaderboard repository
abstract class LeaderboardRepository {
  Future<Result<List<LeaderboardModel>>> getLeaderboard({
    String category = 'productivity',
    String period = 'week',
    String scope = 'global',
    int limit = 100,
  });
  Future<Result<int>> getUserRank(String userId, String category);
}

/// Subscription repository
abstract class SubscriptionRepository {
  Future<Result<SubscriptionModel>> getSubscription();
  Future<Result<SubscriptionModel>> purchase(String productId);
  Future<Result<SubscriptionModel>> restorePurchases();
  Future<Result<bool>> checkFeatureAccess(String feature);
}

/// Report repository
abstract class ReportRepository {
  Future<Result<ReportModel>> generateWeeklyReport();
  Future<Result<ReportModel>> generateMonthlyReport();
  Future<Result<List<ReportModel>>> getReportHistory({int limit = 12});
  Future<Result<String>> exportPdf(String reportId);
  Future<Result<String>> exportCsv(String reportId);
}
