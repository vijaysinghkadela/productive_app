import 'package:flutter_test/flutter_test.dart';
import 'package:focus_guard/core/services/score_calculator_service.dart';
import 'package:focus_guard/core/extensions/string_extensions.dart';
import 'package:focus_guard/core/extensions/duration_extensions.dart';
import 'package:focus_guard/core/extensions/datetime_extensions.dart';
import 'package:focus_guard/core/errors/failure.dart';
import 'package:focus_guard/core/errors/app_exceptions.dart';
import 'package:focus_guard/data/models/user_model.dart';
import 'package:focus_guard/data/models/session_model.dart';
import 'package:focus_guard/data/models/feature_models.dart';

void main() {
  // ============================================================
  // SCORE CALCULATOR TESTS
  // ============================================================
  group('ScoreCalculatorService', () {
    test('perfect day with all bonuses = 100', () {
      final score = ScoreCalculatorService.calculate(
        completedSessions: 5,
        appsBeatGoal: 3,
        allGoalsMet: true,
        allHabitsCompleted: true,
        socialMediaFreeDay: true,
        streakDays: 15,
        journalCompleted: true,
        morningRoutineCompleted: true,
      );
      expect(score, 100); // Capped at 100
    });

    test('worst day with all penalties = 0', () {
      final score = ScoreCalculatorService.calculate(
        socialMediaOverGoalMinutes: 100,
        screenTimeOverGoalMinutes: 100,
        overrideTaps: 10,
        incompleteSessions: 5,
        noSessionBy11am: true,
        habitsNotCompleted: 10,
        poorSleep: true,
      );
      expect(score, 0); // Capped at 0
    });

    test('baseline score with no inputs = 100', () {
      final score = ScoreCalculatorService.calculate();
      expect(score, 100);
    });

    test('social media over goal deduction correct', () {
      final score =
          ScoreCalculatorService.calculate(socialMediaOverGoalMinutes: 10);
      expect(score, 92); // 100 - (10 * 0.8) = 92
    });

    test('completed sessions bonus correct', () {
      final score = ScoreCalculatorService.calculate(completedSessions: 3);
      expect(score, 100); // 100 + 24 = 124, capped at 100
    });

    test('breakdown returns all factors', () {
      final breakdown = ScoreCalculatorService.breakdown(
        socialMediaOverGoalMinutes: 10,
        completedSessions: 2,
      );
      expect(breakdown.length, 16);
      expect(breakdown['social_media_penalty'], -8.0);
      expect(breakdown['focus_sessions_bonus'], 16.0);
    });

    test('scoreTier returns correct tier', () {
      expect(ScoreCalculatorService.scoreTier(90), 'excellent');
      expect(ScoreCalculatorService.scoreTier(75), 'great');
      expect(ScoreCalculatorService.scoreTier(55), 'good');
      expect(ScoreCalculatorService.scoreTier(35), 'fair');
      expect(ScoreCalculatorService.scoreTier(10), 'needs_improvement');
    });
  });

  // ============================================================
  // RESULT TYPE TESTS
  // ============================================================
  group('Result type', () {
    test('Success holds value', () {
      const result = Success(42);
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.valueOrNull, 42);
      expect(result.errorOrNull, null);
    });

    test('Failure holds message', () {
      const result = Failure<int>('Error occurred');
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.valueOrNull, null);
      expect(result.errorOrNull, 'Error occurred');
    });

    test('when() dispatches correctly', () {
      const Result<int> success = Success(42);
      final value = success.when(
        success: (v) => 'got $v',
        failure: (m, c) => 'error: $m',
      );
      expect(value, 'got 42');

      const Result<int> failure = Failure('oops');
      final error = failure.when(
        success: (v) => 'got $v',
        failure: (m, c) => 'error: $m',
      );
      expect(error, 'error: oops');
    });
  });

  // ============================================================
  // APP EXCEPTIONS TESTS
  // ============================================================
  group('AppExceptions', () {
    test('NetworkException status code messages', () {
      expect(const NetworkException('', 401).userMessage,
          'Session expired. Please sign in again.');
      expect(const NetworkException('', 403).userMessage, 'Access denied.');
      expect(const NetworkException('', 429).userMessage,
          'Too many requests. Please wait a moment.');
      expect(const NetworkException('', 500).userMessage,
          'Server error. Please try again later.');
    });

    test('AuthException error code messages', () {
      expect(const AuthException('', 'user-not-found').userMessage,
          'No account found with this email.');
      expect(const AuthException('', 'wrong-password').userMessage,
          'Incorrect password.');
      expect(const AuthException('', 'email-already-in-use').userMessage,
          'This email is already registered.');
    });

    test('PermissionException permission messages', () {
      expect(const PermissionException('', 'usage_stats').userMessage,
          contains('Usage access'));
      expect(const PermissionException('', 'overlay').userMessage,
          contains('Display over other apps'));
    });
  });

  // ============================================================
  // EXTENSION TESTS
  // ============================================================
  group('StringExtension', () {
    test('capitalized', () {
      expect('hello'.capitalized, 'Hello');
      expect(''.capitalized, '');
    });

    test('titleCase', () {
      expect('hello world'.titleCase, 'Hello World');
    });

    test('isValidEmail', () {
      expect('test@example.com'.isValidEmail, true);
      expect('invalid'.isValidEmail, false);
      expect(''.isValidEmail, false);
    });

    test('truncate', () {
      expect('Hello World'.truncate(5), 'Hello...');
      expect('Hi'.truncate(5), 'Hi');
    });

    test('initials', () {
      expect('John Doe'.initials, 'JD');
      expect('Alice'.initials, 'A');
      expect(''.initials, '');
    });

    test('maskedEmail', () {
      expect('john@example.com'.maskedEmail, 'j••n@example.com');
    });
  });

  group('DurationExtension', () {
    test('shortFormat', () {
      expect(const Duration(hours: 1, minutes: 30).shortFormat, '1h 30m');
      expect(const Duration(minutes: 45).shortFormat, '45m');
      expect(const Duration(hours: 2).shortFormat, '2h');
    });

    test('timerFormat', () {
      expect(const Duration(minutes: 5, seconds: 30).timerFormat, '05:30');
      expect(const Duration(hours: 1, minutes: 5).timerFormat, '01:05:00');
    });

    test('totalMinutes', () {
      expect(const Duration(hours: 1, minutes: 30).totalMinutes, 90.0);
    });

    test('percentOf', () {
      const half = Duration(minutes: 30);
      const full = Duration(hours: 1);
      expect(half.percentOf(full), 0.5);
    });
  });

  group('DateTimeExtension', () {
    test('isToday', () {
      expect(DateTime.now().isToday, true);
      expect(DateTime(2020, 1, 1).isToday, false);
    });

    test('isYesterday', () {
      expect(
          DateTime.now().subtract(const Duration(days: 1)).isYesterday, true);
      expect(DateTime.now().isYesterday, false);
    });

    test('startOfDay', () {
      final dt = DateTime(2026, 3, 3, 14, 30);
      expect(dt.startOfDay, DateTime(2026, 3, 3));
    });

    test('dateKey format', () {
      expect(DateTime(2026, 3, 3).dateKey, '2026-03-03');
    });
  });

  // ============================================================
  // MODEL SERIALIZATION TESTS
  // ============================================================
  group('UserModel', () {
    test('fromJson and toJson roundtrip', () {
      final json = {
        'uid': '123',
        'email': 'test@test.com',
        'displayName': 'Test',
        'createdAt': '2026-01-01T00:00:00.000',
        'lastLoginAt': '2026-03-03T00:00:00.000',
        'streakDays': 7,
        'level': 5,
        'totalXp': 1500,
        'subscriptionTier': 'pro',
      };
      final user = UserModel.fromJson(json);
      expect(user.uid, '123');
      expect(user.email, 'test@test.com');
      expect(user.streakDays, 7);
      expect(user.subscriptionTier, 'pro');
      final back = user.toJson();
      expect(back['uid'], '123');
      expect(back['subscriptionTier'], 'pro');
    });

    test('copyWith preserves unchanged fields', () {
      final user = UserModel(
        uid: '1',
        email: 'a@b.com',
        createdAt: DateTime(2026),
        lastLoginAt: DateTime(2026),
        level: 3,
      );
      final updated = user.copyWith(level: 5);
      expect(updated.level, 5);
      expect(updated.email, 'a@b.com');
    });
  });

  group('SessionModel', () {
    test('fromJson and toJson roundtrip', () {
      final json = {
        'id': 's1',
        'userId': 'u1',
        'type': 'Deep Work',
        'startTime': '2026-03-03T10:00:00.000',
        'plannedDurationMinutes': 25,
        'completed': true,
      };
      final session = SessionModel.fromJson(json);
      expect(session.id, 's1');
      expect(session.completed, true);
      expect(session.type, 'Deep Work');
    });
  });

  group('GoalModel', () {
    test('completionRate', () {
      final goal = GoalModel(
        id: 'g1',
        userId: 'u1',
        name: 'Test',
        type: 'screen_time',
        targetValue: 60,
        createdAt: DateTime.now(),
      );
      expect(goal.completionRate, 0.0);
      expect(goal.isCompleted, false);
    });
  });

  group('HabitModel', () {
    test('fromJson with completedDates', () {
      final json = {
        'id': 'h1',
        'userId': 'u1',
        'name': 'Meditate',
        'icon': '🧘',
        'createdAt': '2026-01-01T00:00:00.000',
        'completedDates': ['2026-03-01', '2026-03-02'],
        'totalCompletions': 2,
      };
      final habit = HabitModel.fromJson(json);
      expect(habit.completedDates.length, 2);
      expect(habit.totalCompletions, 2);
    });
  });

  group('AchievementModel', () {
    test('rarity default is common', () {
      final achievement = AchievementModel(
        id: 'a1',
        name: 'First Session',
        description: 'Complete your first focus session',
      );
      expect(achievement.rarity, 'common');
      expect(achievement.xpReward, 100);
    });
  });

  group('SubscriptionModel', () {
    test('isActive for free tier', () {
      const sub = SubscriptionModel(userId: 'u1', tier: 'free');
      expect(sub.isActive, true);
      expect(sub.isPro, false);
    });

    test('isPro for pro tier', () {
      const sub = SubscriptionModel(userId: 'u1', tier: 'pro');
      expect(sub.isPro, true);
      expect(sub.isElite, false);
    });

    test('isElite for elite tier', () {
      const sub = SubscriptionModel(userId: 'u1', tier: 'elite');
      expect(sub.isPro, true); // elite includes pro
      expect(sub.isElite, true);
    });
  });

  group('RewardModel', () {
    test('levelTitle progresses correctly', () {
      expect(const RewardModel(userId: 'u1', level: 1).levelTitle, 'Novice');
      expect(
          const RewardModel(userId: 'u1', level: 5).levelTitle, 'Apprentice');
      expect(const RewardModel(userId: 'u1', level: 10).levelTitle, 'Adept');
      expect(const RewardModel(userId: 'u1', level: 20).levelTitle, 'Expert');
      expect(const RewardModel(userId: 'u1', level: 30).levelTitle, 'Master');
      expect(
          const RewardModel(userId: 'u1', level: 50).levelTitle, 'Focus God');
    });
  });

  group('LeaderboardModel', () {
    test('rankChange computed correctly', () {
      const entry = LeaderboardModel(
        userId: 'u1',
        displayName: 'Test',
        rank: 5,
        previousRank: 8,
        score: 100,
      );
      expect(entry.rankChange, 3); // Went up 3 places
    });
  });

  group('JournalModel', () {
    test('moodEmoji maps correctly', () {
      expect(
          JournalModel(id: 'j1', userId: 'u1', date: DateTime(2026), mood: 1)
              .moodEmoji,
          '😞');
      expect(
          JournalModel(id: 'j2', userId: 'u1', date: DateTime(2026), mood: 5)
              .moodEmoji,
          '🤩');
    });
  });
}
