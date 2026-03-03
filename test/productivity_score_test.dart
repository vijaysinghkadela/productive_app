import 'package:flutter_test/flutter_test.dart';
import 'package:focusguard_pro/core/productivity_score.dart';

void main() {
  group('ProductivityScoreCalculator', () {
    test('returns 100 for a perfect day with no overages', () {
      final score = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 0,
        completedSessions: 0,
        goalsMet: 0,
        streakDays: 0,
        socialMediaFreeDay: false,
      );
      expect(score, 100);
    });

    test('deducts 0.5 per minute over goal', () {
      final score = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 20,
        completedSessions: 0,
        goalsMet: 0,
        streakDays: 0,
        socialMediaFreeDay: false,
      );
      // 100 - (20 * 0.5) = 90
      expect(score, 90);
    });

    test('adds 10 points per completed session', () {
      final score = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 0,
        completedSessions: 3,
        goalsMet: 0,
        streakDays: 0,
        socialMediaFreeDay: false,
      );
      // 100 + (3 * 10) = 130, clamped to 100
      expect(score, 100);
    });

    test('adds points for completed sessions when score is reduced', () {
      final score = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 40,
        completedSessions: 2,
        goalsMet: 0,
        streakDays: 0,
        socialMediaFreeDay: false,
      );
      // 100 - (40 * 0.5) + (2 * 10) = 100 - 20 + 20 = 100
      expect(score, 100);
    });

    test('adds 5 points per goal met', () {
      final score = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 60,
        completedSessions: 0,
        goalsMet: 3,
        streakDays: 0,
        socialMediaFreeDay: false,
      );
      // 100 - 30 + 15 = 85
      expect(score, 85);
    });

    test('adds 2 per streak day, max 20', () {
      final score = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 80,
        completedSessions: 0,
        goalsMet: 0,
        streakDays: 15,
        socialMediaFreeDay: false,
      );
      // 100 - 40 + min(15*2, 20) = 100 - 40 + 20 = 80
      expect(score, 80);
    });

    test('streak bonus is capped at 20', () {
      final score1 = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 100,
        completedSessions: 0,
        goalsMet: 0,
        streakDays: 10,
        socialMediaFreeDay: false,
      );
      final score2 = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 100,
        completedSessions: 0,
        goalsMet: 0,
        streakDays: 50,
        socialMediaFreeDay: false,
      );
      // Both should have +20 streak bonus
      expect(score1, score2);
    });

    test('adds 20 bonus for social media free day', () {
      final score = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 100,
        completedSessions: 0,
        goalsMet: 0,
        streakDays: 0,
        socialMediaFreeDay: true,
      );
      // 100 - 50 + 20 = 70
      expect(score, 70);
    });

    test('score is clamped between 0 and 100', () {
      final lowScore = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 500,
        completedSessions: 0,
        goalsMet: 0,
        streakDays: 0,
        socialMediaFreeDay: false,
      );
      expect(lowScore, 0);

      final highScore = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 0,
        completedSessions: 10,
        goalsMet: 10,
        streakDays: 30,
        socialMediaFreeDay: true,
      );
      expect(highScore, 100);
    });

    test('combined scenario: realistic productivity day', () {
      final score = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 30,
        completedSessions: 4,
        goalsMet: 2,
        streakDays: 7,
        socialMediaFreeDay: false,
      );
      // 100 - 15 + 40 + 10 + 14 = 149 → clamped to 100
      expect(score, 100);
    });

    test('combined scenario: unproductive day', () {
      final score = ProductivityScoreCalculator.calculate(
        overGoalMinutes: 120,
        completedSessions: 0,
        goalsMet: 0,
        streakDays: 0,
        socialMediaFreeDay: false,
      );
      // 100 - 60 = 40
      expect(score, 40);
    });
  });
}
