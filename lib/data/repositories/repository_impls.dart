import 'package:flutter/foundation.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/feature_models.dart';
import '../datasources/local_datasources.dart';
import '../../domain/repositories/repositories.dart';

/// User repository implementation using local datasources (demo mode).
/// In production: add Firebase remote datasource for sync.
class UserRepositoryImpl implements UserRepository {
  final HiveDatasource _hive;
  final SecureStorageDatasource _secure;

  UserRepositoryImpl(this._hive, this._secure);

  @override
  Future<Result<UserModel>> getCurrentUser() async {
    try {
      final data = _hive.getUserData();
      if (data == null) return const Failure('No user logged in');
      return Success(UserModel.fromJson(data));
    } catch (e) {
      return Failure('Failed to get user: $e');
    }
  }

  @override
  Future<Result<UserModel>> getUserById(String uid) async {
    // In production: fetch from Firestore
    return getCurrentUser();
  }

  @override
  Future<Result<void>> updateUser(UserModel user) async {
    try {
      await _hive.saveUserData(user.toJson());
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update user: $e');
    }
  }

  @override
  Future<Result<void>> deleteUser(String uid) async {
    try {
      await _hive.clearBox('user_box');
      await _secure.deleteAll();
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete user: $e');
    }
  }

  @override
  Future<Result<UserModel>> signIn(String email, String password) async {
    try {
      // Demo mode: create local user
      await Future.delayed(const Duration(milliseconds: 800));
      final user = UserModel(
        uid: 'demo_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@').first,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      await _hive.saveUserData(user.toJson());
      return Success(user);
    } catch (e) {
      return Failure('Sign in failed: $e');
    }
  }

  @override
  Future<Result<UserModel>> signUp(
      String email, String password, String displayName) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final user = UserModel(
        uid: 'demo_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      await _hive.saveUserData(user.toJson());
      return Success(user);
    } catch (e) {
      return Failure('Sign up failed: $e');
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _hive.clearBox('user_box');
      await _secure.deleteAll();
      return const Success(null);
    } catch (e) {
      return Failure('Sign out failed: $e');
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Success(null);
  }

  @override
  Future<Result<UserModel>> signInWithGoogle() async =>
      signIn('demo@google.com', 'demo');
  @override
  Future<Result<UserModel>> signInWithApple() async =>
      signIn('demo@apple.com', 'demo');
}

/// Session repository implementation
class SessionRepositoryImpl implements SessionRepository {
  final HiveDatasource _hive;
  SessionRepositoryImpl(this._hive);

  @override
  Future<Result<SessionModel>> startSession(SessionModel session) async {
    try {
      final sessions = _hive.getSessions();
      sessions.insert(0, session.toJson());
      await _hive.saveSessions(sessions);
      return Success(session);
    } catch (e) {
      return Failure('Failed to start session: $e');
    }
  }

  @override
  Future<Result<SessionModel>> endSession(String id,
      {required bool completed}) async {
    try {
      final sessions = _hive.getSessions();
      final idx = sessions.indexWhere((s) => s['id'] == id);
      if (idx == -1) return const Failure('Session not found');
      sessions[idx]['completed'] = completed;
      sessions[idx]['endTime'] = DateTime.now().toIso8601String();
      await _hive.saveSessions(sessions);
      return Success(SessionModel.fromJson(sessions[idx]));
    } catch (e) {
      return Failure('Failed to end session: $e');
    }
  }

  @override
  Future<Result<List<SessionModel>>> getSessionHistory({int limit = 30}) async {
    try {
      final sessions = _hive.getSessions().take(limit).toList();
      return Success(sessions.map((s) => SessionModel.fromJson(s)).toList());
    } catch (e) {
      return Failure('Failed to get sessions: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getSessionStats(String period) async {
    try {
      final sessions = _hive.getSessions();
      final total = sessions.length;
      final completed = sessions.where((s) => s['completed'] == true).length;
      final totalMinutes = sessions.fold<int>(
          0, (sum, s) => sum + (s['actualDurationMinutes'] as int? ?? 0));
      return Success({
        'total': total,
        'completed': completed,
        'totalMinutes': totalMinutes,
        'completionRate': total > 0 ? completed / total : 0.0,
        'averageMinutes': total > 0 ? totalMinutes / total : 0,
      });
    } catch (e) {
      return Failure('Failed to get stats: $e');
    }
  }
}

/// Goal repository implementation
class GoalRepositoryImpl implements GoalRepository {
  final HiveDatasource _hive;
  GoalRepositoryImpl(this._hive);

  static const _key = 'goals';

  List<Map<String, dynamic>> _getAll() {
    final data = _hive.get('settings_box', _key, defaultValue: []);
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<void> _saveAll(List<Map<String, dynamic>> goals) =>
      _hive.put('settings_box', _key, goals);

  @override
  Future<Result<List<GoalModel>>> getGoals({bool activeOnly = true}) async {
    try {
      final goals = _getAll().map((g) => GoalModel.fromJson(g)).toList();
      if (activeOnly) return Success(goals.where((g) => g.isActive).toList());
      return Success(goals);
    } catch (e) {
      return Failure('Failed to get goals: $e');
    }
  }

  @override
  Future<Result<GoalModel>> createGoal(GoalModel goal) async {
    try {
      final goals = _getAll()..add(goal.toJson());
      await _saveAll(goals);
      return Success(goal);
    } catch (e) {
      return Failure('Failed to create goal: $e');
    }
  }

  @override
  Future<Result<void>> updateGoalProgress(String id, int progress) async {
    try {
      final goals = _getAll();
      final idx = goals.indexWhere((g) => g['id'] == id);
      if (idx == -1) return const Failure('Goal not found');
      goals[idx]['currentProgress'] = progress;
      await _saveAll(goals);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update goal: $e');
    }
  }

  @override
  Future<Result<void>> deleteGoal(String id) async {
    try {
      final goals = _getAll()..removeWhere((g) => g['id'] == id);
      await _saveAll(goals);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete goal: $e');
    }
  }
}

/// Habit repository implementation
class HabitRepositoryImpl implements HabitRepository {
  final HiveDatasource _hive;
  HabitRepositoryImpl(this._hive);

  static const _key = 'habits';

  List<Map<String, dynamic>> _getAll() {
    final data = _hive.get('settings_box', _key, defaultValue: []);
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<void> _saveAll(List<Map<String, dynamic>> habits) =>
      _hive.put('settings_box', _key, habits);

  @override
  Future<Result<List<HabitModel>>> getHabits({bool activeOnly = true}) async {
    try {
      final habits = _getAll().map((h) => HabitModel.fromJson(h)).toList();
      if (activeOnly) return Success(habits.where((h) => h.isActive).toList());
      return Success(habits);
    } catch (e) {
      return Failure('Failed to get habits: $e');
    }
  }

  @override
  Future<Result<HabitModel>> createHabit(HabitModel habit) async {
    try {
      final habits = _getAll()..add(habit.toJson());
      await _saveAll(habits);
      return Success(habit);
    } catch (e) {
      return Failure('Failed to create habit: $e');
    }
  }

  @override
  Future<Result<void>> toggleHabitCompletion(String id, String date) async {
    try {
      final habits = _getAll();
      final idx = habits.indexWhere((h) => h['id'] == id);
      if (idx == -1) return const Failure('Habit not found');
      final dates = List<String>.from(habits[idx]['completedDates'] ?? []);
      if (dates.contains(date)) {
        dates.remove(date);
      } else {
        dates.add(date);
      }
      habits[idx]['completedDates'] = dates;
      habits[idx]['totalCompletions'] = dates.length;
      await _saveAll(habits);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to toggle habit: $e');
    }
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    try {
      final habits = _getAll()..removeWhere((h) => h['id'] == id);
      await _saveAll(habits);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete habit: $e');
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getHabitStreaks(String id) async {
    try {
      final habits = _getAll();
      final habit = habits.firstWhere((h) => h['id'] == id, orElse: () => {});
      if (habit.isEmpty) return const Failure('Habit not found');
      return Success({
        'currentStreak': habit['currentStreak'] ?? 0,
        'longestStreak': habit['longestStreak'] ?? 0,
        'totalCompletions': habit['totalCompletions'] ?? 0,
      });
    } catch (e) {
      return Failure('Failed to get streaks: $e');
    }
  }
}

/// Journal repository implementation
class JournalRepositoryImpl implements JournalRepository {
  final HiveDatasource _hive;
  JournalRepositoryImpl(this._hive);

  static const _key = 'journal_entries';

  List<Map<String, dynamic>> _getAll() {
    final data = _hive.get('settings_box', _key, defaultValue: []);
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<void> _saveAll(List<Map<String, dynamic>> entries) =>
      _hive.put('settings_box', _key, entries);

  @override
  Future<Result<List<JournalModel>>> getEntries({int limit = 30}) async {
    try {
      final entries =
          _getAll().take(limit).map((e) => JournalModel.fromJson(e)).toList();
      return Success(entries);
    } catch (e) {
      return Failure('Failed to get journal entries: $e');
    }
  }

  @override
  Future<Result<JournalModel>> createEntry(JournalModel entry) async {
    try {
      final entries = _getAll()..insert(0, entry.toJson());
      await _saveAll(entries);
      return Success(entry);
    } catch (e) {
      return Failure('Failed to create entry: $e');
    }
  }

  @override
  Future<Result<void>> updateEntry(JournalModel entry) async {
    try {
      final entries = _getAll();
      final idx = entries.indexWhere((e) => e['id'] == entry.id);
      if (idx == -1) return const Failure('Entry not found');
      entries[idx] = entry.toJson();
      await _saveAll(entries);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to update entry: $e');
    }
  }

  @override
  Future<Result<void>> deleteEntry(String id) async {
    try {
      final entries = _getAll()..removeWhere((e) => e['id'] == id);
      await _saveAll(entries);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to delete entry: $e');
    }
  }

  @override
  Future<Result<List<JournalModel>>> searchEntries(String query) async {
    try {
      final entries = _getAll()
          .map((e) => JournalModel.fromJson(e))
          .where((e) => e.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
      return Success(entries);
    } catch (e) {
      return Failure('Search failed: $e');
    }
  }
}

// Suppress unused import warnings for demo mode
// ignore_for_file: unused_import
