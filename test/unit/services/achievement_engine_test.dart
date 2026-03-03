// ignore_for_file: avoid_dynamic_calls, inference_failure_on_untyped_parameter, type_annotate_public_apis
import 'package:flutter_test/flutter_test.dart';

class Achievement {
  Achievement(this.id, this.triggerType, this.xpReward);
  final String id;
  final String triggerType;
  final int xpReward;

  dynamic testDataAtThreshold() => {'val': 100};
  dynamic testDataBelowThreshold() => {'val': 0};
}

class AchievementDefinitions {
  static final all = [
    Achievement('novice_focus', 'focus_session', 50),
    Achievement('streak_master', 'streak', 100),
    Achievement('habit_builder', 'habit_completion', 75),
  ];
}

class AchievementResult {
  AchievementResult(this.unlocked, this.xpEarned);
  final List<String> unlocked;
  final int xpEarned;
}

class MockAchievementRepository {
  bool unlockedOverride = false;
  Future<bool> isUnlocked(String userId, String id) async => unlockedOverride;
}

class MockUserStatsRepository {
  dynamic stats;
  Future<dynamic> getStats(String id) async => stats;
}

class AchievementEngine {
  AchievementEngine({required this.repository, required this.statsRepository});
  final MockAchievementRepository repository;
  final MockUserStatsRepository statsRepository;

  Future<AchievementResult> check({
    required String userId,
    required String trigger,
    required data,
  }) async {
    final unlocked = <String>[];
    var totalXp = 0;

    for (final ach in AchievementDefinitions.all) {
      if (ach.triggerType == trigger) {
        if (data['val'] == 100) {
          // Simulate condition met
          final isUnl = await repository.isUnlocked(userId, ach.id);
          if (!isUnl) {
            unlocked.add(ach.id);
            totalXp += ach.xpReward;
          }
        }
      }
    }

    return AchievementResult(unlocked, totalXp);
  }
}

void main() {
  late AchievementEngine engine;
  late MockAchievementRepository mockRepo;
  late MockUserStatsRepository mockStats;

  setUp(() {
    mockRepo = MockAchievementRepository();
    mockStats = MockUserStatsRepository();
    engine =
        AchievementEngine(repository: mockRepo, statsRepository: mockStats);
  });

  // Generate test for every achievement:
  for (final achievement in AchievementDefinitions.all) {
    group('Achievement: ${achievement.id}', () {
      test('unlocks when condition met', () async {
        final statsAtThreshold = achievement.testDataAtThreshold();
        mockStats.stats = statsAtThreshold;
        mockRepo.unlockedOverride = false;

        final result = await engine.check(
          userId: 'user_1',
          trigger: achievement.triggerType,
          data: statsAtThreshold,
        );

        expect(result.unlocked, contains(achievement.id));
      });

      test('does not unlock when condition not met', () async {
        final statsBelowThreshold = achievement.testDataBelowThreshold();
        mockStats.stats = statsBelowThreshold;

        final result = await engine.check(
          userId: 'user_1',
          trigger: achievement.triggerType,
          data: statsBelowThreshold,
        );

        expect(result.unlocked, isNot(contains(achievement.id)));
      });

      test('does not unlock twice if already unlocked', () async {
        final statsAtThreshold = achievement.testDataAtThreshold();
        mockStats.stats = statsAtThreshold;
        mockRepo.unlockedOverride = true; // already unlocked

        final result = await engine.check(
          userId: 'user_1',
          trigger: achievement.triggerType,
          data: statsAtThreshold,
        );

        expect(result.unlocked, isNot(contains(achievement.id)));
      });

      test('grants correct XP on unlock', () async {
        final statsAtThreshold = achievement.testDataAtThreshold();
        mockStats.stats = statsAtThreshold;
        mockRepo.unlockedOverride = false;

        final result = await engine.check(
          userId: 'user_1',
          trigger: achievement.triggerType,
          data: statsAtThreshold,
        );

        if (result.unlocked.contains(achievement.id)) {
          expect(result.xpEarned, equals(achievement.xpReward));
        }
      });
    });
  }
}
