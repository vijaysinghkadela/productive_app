import 'package:focusguard_pro/core/errors/failure.dart';
import 'package:focusguard_pro/data/models/feature_models.dart';
import 'package:focusguard_pro/data/models/session_model.dart';
import 'package:focusguard_pro/data/models/user_model.dart';
import 'package:focusguard_pro/domain/repositories/repositories.dart';

// ============================================================
// AUTH USE CASES
// ============================================================

class SignInUseCase {
  SignInUseCase(this._repo);
  final UserRepository _repo;
  Future<Result<UserModel>> call(String email, String password) =>
      _repo.signIn(email, password);
}

class SignUpUseCase {
  SignUpUseCase(this._repo);
  final UserRepository _repo;
  Future<Result<UserModel>> call(
    String email,
    String password,
    String displayName,
  ) =>
      _repo.signUp(email, password, displayName);
}

class SignOutUseCase {
  SignOutUseCase(this._repo);
  final UserRepository _repo;
  Future<Result<void>> call() => _repo.signOut();
}

class GoogleSignInUseCase {
  GoogleSignInUseCase(this._repo);
  final UserRepository _repo;
  Future<Result<UserModel>> call() => _repo.signInWithGoogle();
}

class AppleSignInUseCase {
  AppleSignInUseCase(this._repo);
  final UserRepository _repo;
  Future<Result<UserModel>> call() => _repo.signInWithApple();
}

class ResetPasswordUseCase {
  ResetPasswordUseCase(this._repo);
  final UserRepository _repo;
  Future<Result<void>> call(String email) => _repo.resetPassword(email);
}

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repo);
  final UserRepository _repo;
  Future<Result<UserModel>> call() => _repo.getCurrentUser();
}

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repo);
  final UserRepository _repo;
  Future<Result<void>> call(UserModel user) => _repo.updateUser(user);
}

class DeleteAccountUseCase {
  DeleteAccountUseCase(this._repo);
  final UserRepository _repo;
  Future<Result<void>> call(String uid) => _repo.deleteUser(uid);
}

// ============================================================
// SESSION USE CASES
// ============================================================

class StartSessionUseCase {
  StartSessionUseCase(this._repo);
  final SessionRepository _repo;
  Future<Result<SessionModel>> call(SessionModel session) =>
      _repo.startSession(session);
}

class EndSessionUseCase {
  EndSessionUseCase(this._repo);
  final SessionRepository _repo;
  Future<Result<SessionModel>> call(String id, {required bool completed}) =>
      _repo.endSession(id, completed: completed);
}

class GetSessionHistoryUseCase {
  GetSessionHistoryUseCase(this._repo);
  final SessionRepository _repo;
  Future<Result<List<SessionModel>>> call({int limit = 30}) =>
      _repo.getSessionHistory(limit: limit);
}

class GetSessionStatsUseCase {
  GetSessionStatsUseCase(this._repo);
  final SessionRepository _repo;
  Future<Result<Map<String, dynamic>>> call(String period) =>
      _repo.getSessionStats(period);
}

// ============================================================
// GOAL USE CASES
// ============================================================

class GetGoalsUseCase {
  GetGoalsUseCase(this._repo);
  final GoalRepository _repo;
  Future<Result<List<GoalModel>>> call({bool activeOnly = true}) =>
      _repo.getGoals(activeOnly: activeOnly);
}

class SetGoalUseCase {
  SetGoalUseCase(this._repo);
  final GoalRepository _repo;
  Future<Result<GoalModel>> call(GoalModel goal) => _repo.createGoal(goal);
}

class UpdateGoalProgressUseCase {
  UpdateGoalProgressUseCase(this._repo);
  final GoalRepository _repo;
  Future<Result<void>> call(String id, int progress) =>
      _repo.updateGoalProgress(id, progress);
}

class DeleteGoalUseCase {
  DeleteGoalUseCase(this._repo);
  final GoalRepository _repo;
  Future<Result<void>> call(String id) => _repo.deleteGoal(id);
}

// ============================================================
// HABIT USE CASES
// ============================================================

class GetHabitsUseCase {
  GetHabitsUseCase(this._repo);
  final HabitRepository _repo;
  Future<Result<List<HabitModel>>> call({bool activeOnly = true}) =>
      _repo.getHabits(activeOnly: activeOnly);
}

class CreateHabitUseCase {
  CreateHabitUseCase(this._repo);
  final HabitRepository _repo;
  Future<Result<HabitModel>> call(HabitModel habit) => _repo.createHabit(habit);
}

class ToggleHabitUseCase {
  ToggleHabitUseCase(this._repo);
  final HabitRepository _repo;
  Future<Result<void>> call(String id, String date) =>
      _repo.toggleHabitCompletion(id, date);
}

class GetHabitStreaksUseCase {
  GetHabitStreaksUseCase(this._repo);
  final HabitRepository _repo;
  Future<Result<Map<String, dynamic>>> call(String id) =>
      _repo.getHabitStreaks(id);
}

// ============================================================
// CHALLENGE USE CASES
// ============================================================

class GetActiveChallengesUseCase {
  GetActiveChallengesUseCase(this._repo);
  final ChallengeRepository _repo;
  Future<Result<List<ChallengeModel>>> call() => _repo.getActiveChallenges();
}

class JoinChallengeUseCase {
  JoinChallengeUseCase(this._repo);
  final ChallengeRepository _repo;
  Future<Result<void>> call(String id) => _repo.joinChallenge(id);
}

// ============================================================
// JOURNAL USE CASES
// ============================================================

class GetJournalEntriesUseCase {
  GetJournalEntriesUseCase(this._repo);
  final JournalRepository _repo;
  Future<Result<List<JournalModel>>> call({int limit = 30}) =>
      _repo.getEntries(limit: limit);
}

class CreateJournalEntryUseCase {
  CreateJournalEntryUseCase(this._repo);
  final JournalRepository _repo;
  Future<Result<JournalModel>> call(JournalModel entry) =>
      _repo.createEntry(entry);
}

class SearchJournalUseCase {
  SearchJournalUseCase(this._repo);
  final JournalRepository _repo;
  Future<Result<List<JournalModel>>> call(String query) =>
      _repo.searchEntries(query);
}

// ============================================================
// ACHIEVEMENT USE CASES
// ============================================================

class GetAchievementsUseCase {
  GetAchievementsUseCase(this._repo);
  final AchievementRepository _repo;
  Future<Result<List<AchievementModel>>> call() => _repo.getAchievements();
}

class UnlockAchievementUseCase {
  UnlockAchievementUseCase(this._repo);
  final AchievementRepository _repo;
  Future<Result<AchievementModel>> call(String id) =>
      _repo.unlockAchievement(id);
}

// ============================================================
// AI COACHING USE CASES
// ============================================================

class AskAiCoachUseCase {
  AskAiCoachUseCase(this._repo);
  final AiCoachingRepository _repo;
  Future<Result<String>> call(String message, Map<String, dynamic> context) =>
      _repo.getAiResponse(message, context);
}

class GetDailyInsightUseCase {
  GetDailyInsightUseCase(this._repo);
  final AiCoachingRepository _repo;
  Future<Result<String>> call(Map<String, dynamic> stats) =>
      _repo.getDailyInsight(stats);
}

// ============================================================
// LEADERBOARD USE CASES
// ============================================================

class GetLeaderboardUseCase {
  GetLeaderboardUseCase(this._repo);
  final LeaderboardRepository _repo;
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
  GetSubscriptionUseCase(this._repo);
  final SubscriptionRepository _repo;
  Future<Result<SubscriptionModel>> call() => _repo.getSubscription();
}

class PurchasePlanUseCase {
  PurchasePlanUseCase(this._repo);
  final SubscriptionRepository _repo;
  Future<Result<SubscriptionModel>> call(String productId) =>
      _repo.purchase(productId);
}

class RestorePurchasesUseCase {
  RestorePurchasesUseCase(this._repo);
  final SubscriptionRepository _repo;
  Future<Result<SubscriptionModel>> call() => _repo.restorePurchases();
}

class CheckFeatureAccessUseCase {
  CheckFeatureAccessUseCase(this._repo);
  final SubscriptionRepository _repo;
  Future<Result<bool>> call(String feature) =>
      _repo.checkFeatureAccess(feature);
}

// ============================================================
// REPORT USE CASES
// ============================================================

class GenerateWeeklyReportUseCase {
  GenerateWeeklyReportUseCase(this._repo);
  final ReportRepository _repo;
  Future<Result<ReportModel>> call() => _repo.generateWeeklyReport();
}

class GenerateMonthlyReportUseCase {
  GenerateMonthlyReportUseCase(this._repo);
  final ReportRepository _repo;
  Future<Result<ReportModel>> call() => _repo.generateMonthlyReport();
}

class ExportPdfUseCase {
  ExportPdfUseCase(this._repo);
  final ReportRepository _repo;
  Future<Result<String>> call(String reportId) => _repo.exportPdf(reportId);
}

class ExportCsvUseCase {
  ExportCsvUseCase(this._repo);
  final ReportRepository _repo;
  Future<Result<String>> call(String reportId) => _repo.exportCsv(reportId);
}
