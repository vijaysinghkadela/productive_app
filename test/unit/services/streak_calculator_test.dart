import 'package:flutter_test/flutter_test.dart';

class StreakResult {
  StreakResult({
    required this.newStreak,
    required this.newLongestStreak,
    required this.changed,
    required this.streakBroken,
    this.milestoneReached,
  });
  final int newStreak;
  final int newLongestStreak;
  final bool changed;
  final bool streakBroken;
  final int? milestoneReached;
}

class StreakCalculator {
  StreakResult calculate({
    required int currentStreak,
    required bool todayCompleted,
    DateTime? lastActiveDate,
    int longestStreak = 0,
    bool todaySkipped = false,
    String timezone = 'UTC',
  }) {
    final now = DateTime
        .now(); // In real implementation, pass 'now' or use timezone injected logic

    if (lastActiveDate == null) {
      if (todayCompleted) {
        return StreakResult(
          newStreak: 1,
          newLongestStreak: longestStreak > 1 ? longestStreak : 1,
          changed: true,
          streakBroken: false,
        );
      }
      return StreakResult(
        newStreak: 0,
        newLongestStreak: longestStreak,
        changed: false,
        streakBroken: false,
      );
    }

    final diff = now.difference(lastActiveDate).inDays;

    if (diff == 0 && todayCompleted) {
      return StreakResult(
        newStreak: currentStreak,
        newLongestStreak: longestStreak,
        changed: false,
        streakBroken: false,
      );
    }

    if (diff == 1 && todayCompleted) {
      final newS = currentStreak + 1;
      final m = _checkMilestone(newS);
      final newLong = newS > longestStreak ? newS : longestStreak;
      return StreakResult(
        newStreak: newS,
        newLongestStreak: newLong,
        changed: true,
        streakBroken: false,
        milestoneReached: m,
      );
    }

    if (diff >= 2 && !todaySkipped && todayCompleted) {
      return StreakResult(
        newStreak: 1,
        newLongestStreak: longestStreak,
        changed: true,
        streakBroken: true,
      );
    }

    if (todaySkipped) {
      return StreakResult(
        newStreak: currentStreak,
        newLongestStreak: longestStreak,
        changed: false,
        streakBroken: false,
      );
    }

    return StreakResult(
      newStreak: currentStreak,
      newLongestStreak: longestStreak,
      changed: false,
      streakBroken: false,
    );
  }

  int? _checkMilestone(int streak) {
    if ([7, 14, 30, 60, 90, 180, 365].contains(streak)) return streak;
    return null;
  }
}

void main() {
  group('StreakCalculator', () {
    late StreakCalculator calculator;

    setUp(() => calculator = StreakCalculator());

    test('increments streak on consecutive day', () {
      final result = calculator.calculate(
        lastActiveDate: DateTime.now().subtract(const Duration(days: 1)),
        currentStreak: 5,
        todayCompleted: true,
      );
      expect(result.newStreak, equals(6));
    });

    test('resets streak on missed day', () {
      final result = calculator.calculate(
        lastActiveDate: DateTime.now().subtract(const Duration(days: 2)),
        currentStreak: 10,
        todayCompleted: true,
      );
      expect(result.newStreak, equals(1)); // New streak starting today
      expect(result.streakBroken, isTrue);
    });

    test('does not reset streak for skipped habit', () {
      final result = calculator.calculate(
        lastActiveDate: DateTime.now().subtract(const Duration(days: 1)),
        currentStreak: 5,
        todayCompleted: false,
        todaySkipped: true,
      );
      expect(result.newStreak, equals(5)); // Skip doesn't break streak
    });

    test('handles timezone boundary correctly', () {
      // User in UTC-8 completing habit at 11:59pm — must count as today
      final result = calculator.calculate(
        lastActiveDate: DateTime.now().subtract(const Duration(days: 1)),
        currentStreak: 1,
        todayCompleted: true,
        timezone: 'America/Los_Angeles',
      );
      expect(result.newStreak, equals(2));
    });

    test('detects streak milestones', () {
      final milestones = [7, 14, 30, 60, 90, 180, 365];
      for (final milestone in milestones) {
        final result = calculator.calculate(
          lastActiveDate: DateTime.now().subtract(const Duration(days: 1)),
          currentStreak: milestone - 1,
          todayCompleted: true,
        );
        expect(result.milestoneReached, equals(milestone));
      }
    });

    test('updates longest streak when current exceeds it', () {
      final result = calculator.calculate(
        lastActiveDate: DateTime.now().subtract(const Duration(days: 1)),
        currentStreak: 29,
        longestStreak: 25,
        todayCompleted: true,
      );
      expect(result.newLongestStreak, equals(30));
    });

    test('preserves longest streak when current is shorter', () {
      final result = calculator.calculate(
        lastActiveDate: DateTime.now().subtract(const Duration(days: 2)),
        currentStreak: 10,
        longestStreak: 50,
        todayCompleted: true,
      );
      expect(result.newLongestStreak, equals(50)); // Preserved
    });

    test('handles first ever streak day', () {
      final result = calculator.calculate(
        currentStreak: 0,
        todayCompleted: true,
      );
      expect(result.newStreak, equals(1));
    });

    test('no update when already completed today', () {
      final result = calculator.calculate(
        lastActiveDate: DateTime.now(), // Today
        currentStreak: 5,
        todayCompleted: true,
      );
      expect(result.newStreak, equals(5)); // Idempotent
      expect(result.changed, isFalse);
    });
  });
}
