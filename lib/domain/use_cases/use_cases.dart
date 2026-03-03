import '../../core/errors/failure.dart';
import '../../domain/repositories/repositories.dart';
import '../../data/models/user_model.dart';
import '../../data/models/session_model.dart';
import '../../data/models/feature_models.dart';

// ============================================================
// AUTH USE CASES
// ============================================================

class SignInUseCase {
  final UserRepository _repo;
  SignInUseCase(this._repo);
  Future<Result<UserModel>> call(String email, String password) =>
      _repo.signIn(email, password);
}

class SignUpUseCase {
  final UserRepository _repo;
  SignUpUseCase(this._repo);
  Future<Result<UserModel>> call(
          String email, String password, String displayName) =>
      _repo.signUp(email, password, displayName);
}

class SignOutUseCase {
  final UserRepository _repo;
  SignOutUseCase(this._repo);
  Future<Result<void>> call() => _repo.signOut();
}

class GoogleSignInUseCase {
  final UserRepository _repo;
  GoogleSignInUseCase(this._repo);
  Future<Result<UserModel>> call() => _repo.signInWithGoogle();
}

class AppleSignInUseCase {
  final UserRepository _repo;
  AppleSignInUseCase(this._repo);
  Future<Result<UserModel>> call() => _repo.signInWithApple();
}

class ResetPasswordUseCase {
  final UserRepository _repo;
  ResetPasswordUseCase(this._repo);
  Future<Result<void>> call(String email) => _repo.resetPassword(email);
}

class GetCurrentUserUseCase {
  final UserRepository _repo;
  GetCurrentUserUseCase(this._repo);
  Future<Result<UserModel>> call() => _repo.getCurrentUser();
}

class UpdateProfileUseCase {
  final UserRepository _repo;
  UpdateProfileUseCase(this._repo);
  Future<Result<void>> call(UserModel user) => _repo.updateUser(user);
}

class DeleteAccountUseCase {
  final UserRepository _repo;
  DeleteAccountUseCase(this._repo);
  Future<Result<void>> call(String uid) => _repo.deleteUser(uid);
}

// ============================================================
// SESSION USE CASES
// ============================================================

class StartSessionUseCase {
  final SessionRepository _repo;
  StartSessionUseCase(this._repo);
  Future<Result<SessionModel>> call(SessionModel session) =>
      _repo.startSession(session);
}

class EndSessionUseCase {
  final SessionRepository _repo;
  EndSessionUseCase(this._repo);
  Future<Result<SessionModel>> call(String id, {required bool completed}) =>
      _repo.endSession(id, completed: completed);
}

class GetSessionHistoryUseCase {
  final SessionRepository _repo;
  GetSessionHistoryUseCase(this._repo);
  Future<Result<List<SessionModel>>> call({int limit = 30}) =>
      _repo.getSessionHistory(limit: limit);
}

class GetSessionStatsUseCase {
  final SessionRepository _repo;
  GetSessionStatsUseCase(this._repo);
  Future<Result<Map<String, dynamic>>> call(String period) =>
      _repo.getSessionStats(period);
}

// ============================================================
// GOAL USE CASES
// ============================================================

class GetGoalsUseCase {
  final GoalRepository _repo;
  GetGoalsUseCase(this._repo);
  Future<Result<List<GoalModel>>> call({bool activeOnly = true}) =>
      _repo.getGoals(activeOnly: activeOnly);
}

class SetGoalUseCase {
  final GoalRepository _repo;
  SetGoalUseCase(this._repo);
  Future<Result<GoalModel>> call(GoalModel goal) => _repo.createGoal(goal);
}

class UpdateGoalProgressUseCase {
  final GoalRepository _repo;
  UpdateGoalProgressUseCase(this._repo);
  Future<Result<void>> call(String id, int progress) =>
      _repo.updateGoalProgress(id, progress);
}

class DeleteGoalUseCase {
  final GoalRepository _repo;
  DeleteGoalUseCase(this._repo);
  Future<Result<void>> call(String id) => _repo.deleteGoal(id);
}

// ============================================================
// HABIT USE CASES
// ============================================================

class GetHabitsUseCase {
  final HabitRepository _repo;
  GetHabitsUseCase(this._repo);
  Future<Result<List<HabitModel>>> call({bool activeOnly = true}) =>
      _repo.getHabits(activeOnly: activeOnly);
}

class CreateHabitUseCase {
  final HabitRepository _repo;
  CreateHabitUseCase(this._repo);
  Future<Result<HabitModel>> call(HabitModel habit) => _repo.createHabit(habit);
}

class ToggleHabitUseCase {
  final HabitRepository _repo;
  ToggleHabitUseCase(this._repo);
  Future<Result<void>> call(String id, String date) =>
      _repo.toggleHabitCompletion(id, date);
}

class GetHabitStreaksUseCase {
  final HabitRepository _repo;
  GetHabitStreaksUseCase(this._repo);
  Future<Result<Map<String, dynamic>>> call(String id) =>
      _repo.getHabitStreaks(id);
}

// ============================================================
// CHALLENGE USE CASES
// ============================================================

class GetActiveChallengesUseCase {
  final ChallengeRepository _repo;
  GetActiveChallengesUseCase(this._repo);
  Future<Result<List<ChallengeModel>>> call() => _repo.getActiveChallenges();
}

class JoinChallengeUseCase {
  final ChallengeRepository _repo;
  JoinChallengeUseCase(this._repo);
  Future<Result<void>> call(String id) => _repo.joinChallenge(id);
}

// ============================================================
// JOURNAL USE CASES
// ============================================================

class GetJournalEntriesUseCase {
  final JournalRepository _repo;
  GetJournalEntriesUseCase(this._repo);
  Future<Result<List<JournalModel>>> call({int limit = 30}) =>
      _repo.getEntries(limit: limit);
}

class CreateJournalEntryUseCase {
  final JournalRepository _repo;
  CreateJournalEntryUseCase(this._repo);
  Future<Result<JournalModel>> call(JournalModel entry) =>
      _repo.createEntry(entry);
}

class SearchJournalUseCase {
  final JournalRepository _repo;
  SearchJournalUseCase(this._repo);
  Future<Result<List<JournalModel>>> call(String query) =>
      _repo.searchEntries(query);
}

// ============================================================
// ACHIEVEMENT USE CASES
// ============================================================

class GetAchievementsUseCase {
  final AchievementRepository _repo;
  GetAchievementsUseCase(this._repo);
  Future<Result<List<AchievementModel>>> call() => _repo.getAchievements();
}

class UnlockAchievementUseCase {
  final AchievementRepository _repo;
  UnlockAchievementUseCase(this._repo);
  Future<Result<AchievementModel>> call(String id) =>
      _repo.unlockAchievement(id);
}

// ============================================================
// AI COACHING USE CASES
// ============================================================

class AskAiCoachUseCase {
  final AiCoachingRepository _repo;
  AskAiCoachUseCase(this._repo);
  Future<Result<String>> call(String message, Map<String, dynamic> context) =>
      _repo.getAiResponse(message, context);
}

class GetDailyInsightUseCase {
  final AiCoachingRepository _repo;
  GetDailyInsightUseCase(this._repo);
  Future<Result<String>> call(Map<String, dynamic> stats) =>
      _repo.getDailyInsight(stats);
}

// ============================================================
// LEADERBOARD USE CASES
// ============================================================

class GetLeaderboardUseCase {
  final LeaderboardRepository _repo;
  GetLeaderboardUseCase(this._repo);
  Future<Result<List<LeaderboardModel>>> call({
    String category = 'productivity',
    String period = 'week',
    String scope = 'global',
  }) =>
      _repo.getLeaderboard(category: category, period: period, scope: scope);
}

// ============================================================
// SUBSCRIPTION USE CASES
// ============================================================

class GetSubscriptionUseCase {
  final SubscriptionRepository _repo;
  GetSubscriptionUseCase(this._repo);
  Future<Result<SubscriptionModel>> call() => _repo.getSubscription();
}

class PurchasePlanUseCase {
  final SubscriptionRepository _repo;
  PurchasePlanUseCase(this._repo);
  Future<Result<SubscriptionModel>> call(String productId) =>
      _repo.purchase(productId);
}

class RestorePurchasesUseCase {
  final SubscriptionRepository _repo;
  RestorePurchasesUseCase(this._repo);
  Future<Result<SubscriptionModel>> call() => _repo.restorePurchases();
}

class CheckFeatureAccessUseCase {
  final SubscriptionRepository _repo;
  CheckFeatureAccessUseCase(this._repo);
  Future<Result<bool>> call(String feature) =>
      _repo.checkFeatureAccess(feature);
}

// ============================================================
// REPORT USE CASES
// ============================================================

class GenerateWeeklyReportUseCase {
  final ReportRepository _repo;
  GenerateWeeklyReportUseCase(this._repo);
  Future<Result<ReportModel>> call() => _repo.generateWeeklyReport();
}

class GenerateMonthlyReportUseCase {
  final ReportRepository _repo;
  GenerateMonthlyReportUseCase(this._repo);
  Future<Result<ReportModel>> call() => _repo.generateMonthlyReport();
}

class ExportPdfUseCase {
  final ReportRepository _repo;
  ExportPdfUseCase(this._repo);
  Future<Result<String>> call(String reportId) => _repo.exportPdf(reportId);
}

class ExportCsvUseCase {
  final ReportRepository _repo;
  ExportCsvUseCase(this._repo);
  Future<Result<String>> call(String reportId) => _repo.exportCsv(reportId);
}
