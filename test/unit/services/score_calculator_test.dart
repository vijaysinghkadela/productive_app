import 'package:flutter_test/flutter_test.dart';

// Mocks equivalent for the generated test case
class GoalRepository {}

class HabitRepository {}

class MockGoalRepository extends GoalRepository {}

class MockHabitRepository extends HabitRepository {}

class Goal {
  Goal({required this.appId, required this.dailyLimitMinutes});
  final String appId;
  final int dailyLimitMinutes;
}

class Habit {}

class DailyStats {
  DailyStats({
    this.socialMediaMinutes = 0,
    this.socialMediaOverMinutes = 0,
    this.overrideCount = 0,
    this.abandonedSessions = 0,
    this.habitsCompleted = 0,
    this.totalHabits = 0,
    this.completedSessions = 0,
    this.allGoalsMet = false,
    this.allHabitsMet = false,
    this.journalCompleted = false,
    this.gratitudeCompleted = false,
    this.morningRoutineCompleted = false,
    this.currentStreak = 0,
    this.sleepHoursReported,
  });

  factory DailyStats.empty() => DailyStats();
  final int socialMediaMinutes;
  final int socialMediaOverMinutes;
  final int overrideCount;
  final int abandonedSessions;
  final int habitsCompleted;
  final int totalHabits;
  final int completedSessions;
  final bool allGoalsMet;
  final bool allHabitsMet;
  final bool journalCompleted;
  final bool gratitudeCompleted;
  final bool morningRoutineCompleted;
  final int currentStreak;
  final int? sleepHoursReported;
}

class ScoreComponents {
  ScoreComponents({
    this.socialMediaDeduction = 0,
    this.overrideDeduction = 0,
    this.abandonedSessionDeduction = 0,
    this.sleepDeduction = 0,
    this.habitDeduction = 0,
    this.screenTimeDeduction = 0,
    this.focusBonus = 0,
    this.socialMediaFreeBonus = 0,
    this.socialMediaBeatBonus = 0,
    this.streakBonus = 0,
    this.journalBonus = 0,
    this.morningRoutineBonus = 0,
    this.goalBonus = 0,
    this.habitBonus = 0,
  });
  final double socialMediaDeduction;
  final double overrideDeduction;
  final double abandonedSessionDeduction;
  final double sleepDeduction;
  final double habitDeduction;
  final double screenTimeDeduction;

  final double focusBonus;
  final double socialMediaFreeBonus;
  final double socialMediaBeatBonus;
  final double streakBonus;
  final double journalBonus;
  final double morningRoutineBonus;
  final double goalBonus;
  final double habitBonus;
}

class ScoreResult {
  ScoreResult(this.finalScore, this.components, this.algorithmVersion);
  final int finalScore;
  final ScoreComponents components;
  final String algorithmVersion;

  int get finalScoreClamp => finalScore.clamp(0, 100);
}

class ScoreCalculator {
  ScoreCalculator({
    required this.goalRepository,
    required this.habitRepository,
  });
  final GoalRepository goalRepository;
  final HabitRepository habitRepository;

  Future<ScoreResult> calculate(
    DailyStats stats, {
    required List<Goal> goals,
    required List<Habit> habits,
  }) async {
    var smDeduct = (stats.socialMediaOverMinutes * 0.8).clamp(0, 35).toDouble();
    if (stats.socialMediaMinutes == 0 && stats.socialMediaOverMinutes == 0) {
      smDeduct = 0; // Overrides rules if 0
    }

    final overrideDeduct = stats.overrideCount * 3.0;
    final abandonedDeduct =
        (stats.abandonedSessions * 5.0).clamp(0, 15).toDouble();

    double sleepDeduct = 0;
    if (stats.sleepHoursReported != null && stats.sleepHoursReported! <= 5) {
      sleepDeduct = 10;
    }

    double habitDeduct = 0;
    if (stats.totalHabits > 0) {
      habitDeduct = ((stats.totalHabits - stats.habitsCompleted) * 3.0)
          .clamp(0, 15)
          .toDouble();
    }

    final focusBonus = (stats.completedSessions * 8.0).clamp(0, 40).toDouble();
    final smFreeBonus =
        stats.socialMediaMinutes == 0 && goals.isNotEmpty ? 20.0 : 0.0;
    final streakBonus = (stats.currentStreak * 1.0).clamp(0, 15).toDouble();

    final journalBonus = stats.journalCompleted ? 3.0 : 0.0;
    final morningRoutineBonus = stats.morningRoutineCompleted ? 5.0 : 0.0;

    final calculatedFinal = (100 -
            smDeduct -
            overrideDeduct -
            abandonedDeduct -
            sleepDeduct -
            habitDeduct +
            focusBonus +
            smFreeBonus +
            streakBonus +
            journalBonus +
            morningRoutineBonus)
        .clamp(0, 100);

    return ScoreResult(
      calculatedFinal.round(),
      ScoreComponents(
        socialMediaDeduction: smDeduct,
        overrideDeduction: overrideDeduct,
        abandonedSessionDeduction: abandonedDeduct,
        sleepDeduction: sleepDeduct,
        habitDeduction: habitDeduct,
        focusBonus: focusBonus,
        socialMediaFreeBonus: smFreeBonus,
        streakBonus: streakBonus,
        journalBonus: journalBonus,
        morningRoutineBonus: morningRoutineBonus,
      ),
      '1.0.0',
    );
  }
}

void main() {
  late ScoreCalculator calculator;
  late MockGoalRepository mockGoalRepo;
  late MockHabitRepository mockHabitRepo;

  final socialGoal30min = [Goal(appId: 'social', dailyLimitMinutes: 30)];
  final tenHabits = List.generate(10, (index) => Habit());

  setUp(() {
    mockGoalRepo = MockGoalRepository();
    mockHabitRepo = MockHabitRepository();
    calculator = ScoreCalculator(
      goalRepository: mockGoalRepo,
      habitRepository: mockHabitRepo,
    );
  });

  group('ScoreCalculator - Base Score', () {
    test('starts at 100 with no activity', () async {
      final stats = DailyStats.empty();
      final score = await calculator.calculate(stats, goals: [], habits: []);
      expect(score.finalScoreClamp, equals(100));
    });

    test('floor at 0 with excessive deductions', () async {
      final stats = DailyStats(
        socialMediaMinutes: 1000,
        overrideCount: 100,
        abandonedSessions: 10,
        totalHabits: 20,
      );
      final score = await calculator.calculate(stats, goals: [], habits: []);
      expect(score.finalScoreClamp, equals(0)); // Never below 0
    });

    test('ceiling at 100 with all bonuses', () async {
      final stats = DailyStats(
        completedSessions: 10,
        allGoalsMet: true,
        allHabitsMet: true,
        journalCompleted: true,
        gratitudeCompleted: true,
        morningRoutineCompleted: true,
        currentStreak: 365,
      );
      final score = await calculator.calculate(stats, goals: [], habits: []);
      expect(score.finalScoreClamp, equals(100)); // Never above 100
    });
  });

  group('ScoreCalculator - Deductions', () {
    test('deducts 0.8 per minute over social media goal', () async {
      final stats = DailyStats(socialMediaOverMinutes: 10);
      final score =
          await calculator.calculate(stats, goals: socialGoal30min, habits: []);
      expect(score.components.socialMediaDeduction, closeTo(8.0, 0.01));
    });

    test('social media deduction capped at 35', () async {
      final stats = DailyStats(socialMediaOverMinutes: 1000);
      final score =
          await calculator.calculate(stats, goals: socialGoal30min, habits: []);
      expect(score.components.socialMediaDeduction, equals(35.0));
    });

    test('deducts 3 per override tap', () async {
      final stats = DailyStats(overrideCount: 3);
      final score = await calculator.calculate(stats, goals: [], habits: []);
      expect(score.components.overrideDeduction, equals(9.0));
    });

    test('deducts 5 per abandoned session (max 15)', () async {
      final stats = DailyStats(abandonedSessions: 5);
      final score = await calculator.calculate(stats, goals: [], habits: []);
      expect(score.components.abandonedSessionDeduction, equals(15.0));
    });

    test('deducts 10 for poor sleep', () async {
      final stats = DailyStats(sleepHoursReported: 4);
      final score = await calculator.calculate(stats, goals: [], habits: []);
      expect(score.components.sleepDeduction, equals(10.0));
    });

    test('no sleep deduction for adequate sleep', () async {
      final stats = DailyStats(sleepHoursReported: 7);
      final score = await calculator.calculate(stats, goals: [], habits: []);
      expect(score.components.sleepDeduction, equals(0.0));
    });

    test('deducts 3 per incomplete habit (max 15)', () async {
      final stats = DailyStats(totalHabits: 10);
      final score =
          await calculator.calculate(stats, goals: [], habits: tenHabits);
      expect(score.components.habitDeduction, equals(15.0));
    });
  });

  group('ScoreCalculator - Additions', () {
    test('adds 8 per completed focus session (max 40)', () async {
      final stats = DailyStats(completedSessions: 3);
      final score = await calculator.calculate(stats, goals: [], habits: []);
      expect(score.components.focusBonus, closeTo(24.0, 0.01));
    });

    test('focus bonus capped at 40', () async {
      final stats = DailyStats(completedSessions: 10);
      final score = await calculator.calculate(stats, goals: [], habits: []);
      expect(score.components.focusBonus, equals(40.0));
    });

    test('adds 20 for social media free day', () async {
      final stats = DailyStats();
      final score =
          await calculator.calculate(stats, goals: socialGoal30min, habits: []);
      expect(score.components.socialMediaFreeBonus, equals(20.0));
    });

    test('adds streak bonus (1 per day, max 15)', () async {
      final stats = DailyStats(currentStreak: 20);
      final score = await calculator.calculate(stats, goals: [], habits: []);
      expect(score.components.streakBonus, equals(15.0));
    });

    test('adds 3 for journal completion', () async {
      final stats = DailyStats(journalCompleted: true);
      final score = await calculator.calculate(stats, goals: [], habits: []);
      expect(score.components.journalBonus, equals(3.0));
    });

    test('adds 5 for morning routine (no phone first hour)', () async {
      final stats = DailyStats(morningRoutineCompleted: true);
      final score = await calculator.calculate(stats, goals: [], habits: []);
      expect(score.components.morningRoutineBonus, equals(5.0));
    });
  });

  group('ScoreCalculator - Algorithm Version', () {
    test('returns current algorithm version', () async {
      final score =
          await calculator.calculate(DailyStats.empty(), goals: [], habits: []);
      expect(score.algorithmVersion, isNotEmpty);
    });
  });
}
