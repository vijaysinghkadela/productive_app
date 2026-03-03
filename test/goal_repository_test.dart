import 'package:flutter_test/flutter_test.dart';
import 'package:focus_guard/domain/entities/goal.dart';

void main() {
  group('AppGoal', () {
    test('creates AppGoal with required fields', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 30,
      );

      expect(goal.packageName, 'com.instagram.android');
      expect(goal.appName, 'Instagram');
      expect(goal.dailyLimitMinutes, 30);
      expect(goal.currentUsageMinutes, 0);
    });

    test('calculates minutesOver correctly when over limit', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 30,
        currentUsageMinutes: 45,
      );

      expect(goal.minutesOver, 15);
    });

    test('minutesOver is 0 when under limit', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 30,
        currentUsageMinutes: 20,
      );

      expect(goal.minutesOver, 0);
    });

    test('minutesOver is 0 when exactly at limit', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 30,
        currentUsageMinutes: 30,
      );

      expect(goal.minutesOver, 0);
    });

    test('progress calculates correctly', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 60,
        currentUsageMinutes: 30,
      );

      expect(goal.progress, 0.5);
    });

    test('progress is capped at 2.0 when way over limit', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 30,
        currentUsageMinutes: 90,
      );

      expect(goal.progress, 2.0);
    });

    test('isOverLimit is true when exceeded', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 30,
        currentUsageMinutes: 31,
      );

      expect(goal.isOverLimit, true);
    });

    test('isOverLimit is false when under or at limit', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 30,
        currentUsageMinutes: 30,
      );

      expect(goal.isOverLimit, false);
    });

    test('isGoalMet is true when at or under limit', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 30,
        currentUsageMinutes: 30,
      );

      expect(goal.isGoalMet, true);
    });

    test('minutesRemaining calculates correctly', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 60,
        currentUsageMinutes: 25,
      );

      expect(goal.minutesRemaining, 35);
    });

    test('minutesRemaining is 0 when over limit', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 30,
        currentUsageMinutes: 50,
      );

      expect(goal.minutesRemaining, 0);
    });

    test('copyWith creates a modified copy', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 30,
        currentUsageMinutes: 10,
      );

      final updated = goal.copyWith(currentUsageMinutes: 20);

      expect(updated.currentUsageMinutes, 20);
      expect(updated.packageName, 'com.instagram.android');
      expect(updated.dailyLimitMinutes, 30);
    });

    test('toMap and fromMap roundtrip preserves data', () {
      final goal = AppGoal(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        dailyLimitMinutes: 45,
        currentUsageMinutes: 20,
      );

      final map = goal.toMap();
      final restored = AppGoal.fromMap(map);

      expect(restored.packageName, goal.packageName);
      expect(restored.appName, goal.appName);
      expect(restored.dailyLimitMinutes, goal.dailyLimitMinutes);
      expect(restored.currentUsageMinutes, goal.currentUsageMinutes);
    });
  });
}
