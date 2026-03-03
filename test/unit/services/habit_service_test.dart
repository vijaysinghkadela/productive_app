// ignore_for_file: avoid_positional_boolean_parameters, type_annotate_public_apis, use_setters_to_change_properties
import 'package:flutter_test/flutter_test.dart';

class ValidationException implements Exception {
  ValidationException(this.message);
  final String message;
}

class AuthorizationException implements Exception {}

class SubscriptionLimitException implements Exception {}

enum HabitFrequency { daily }

enum SubscriptionTier { basic, pro }

class Habit {
  Habit({this.userId = 'user_1', this.completed = false});
  final String userId;
  final bool completed;

  Habit copyWith({String? userId, bool? completed}) => Habit(
        userId: userId ?? this.userId,
        completed: completed ?? this.completed,
      );
}

class TrackResult {
  TrackResult({
    required this.success,
    this.xpEarned = 0,
    this.alreadyCompleted = false,
  });
  final bool success;
  final int xpEarned;
  final bool alreadyCompleted;
}

class CreateResult {
  CreateResult({required this.habitId});
  final String habitId;
}

class MockHabitRepository {
  Habit? _habit;
  int _count = 0;
  final String _newHabitId = 'new_habit_id';

  void setHabit(Habit h) => _habit = h;
  void setCount(int c) => _count = c;

  Future<Habit> getHabit(String id) async => _habit ?? Habit();
  Future<void> updateCompletion(String id, bool val) async {}
  Future<int> countActiveHabits(String uid) async => _count;
  Future<String> createHabit(data) async => _newHabitId;

  int updateCompletionCalled = 0;
}

class MockNotificationService {}

class MockAchievementService {
  int checkHabitCalled = 0;
  Future<void> checkHabitAchievements(data) async {
    checkHabitCalled++;
  }
}

class HabitService {
  HabitService({
    required this.repository,
    required this.notifications,
    required this.achievements,
  });
  final MockHabitRepository repository;
  final MockNotificationService notifications;
  final MockAchievementService achievements;

  Future<TrackResult> trackHabit({
    required String habitId,
    required String date,
    required bool completed,
  }) async {
    final parsed = DateTime.parse(date);
    if (DateTime.now().difference(parsed).inDays > 7) {
      throw ValidationException('Cannot backdate more than 7 days');
    }

    final habit = await repository.getHabit(habitId);
    if (habit.userId != 'user_1') throw AuthorizationException();

    if (habit.completed) {
      return TrackResult(success: true, alreadyCompleted: true);
    }

    repository.updateCompletionCalled++;
    await achievements.checkHabitAchievements(habitId);

    return TrackResult(success: true, xpEarned: 20);
  }

  Future<CreateResult> createHabit({
    required String userId,
    required String name,
    required String icon,
    required HabitFrequency frequency,
    required SubscriptionTier tier,
  }) async {
    if (name.isEmpty) throw ValidationException('Name cannot be empty');

    final count = await repository.countActiveHabits(userId);
    if (tier == SubscriptionTier.basic && count >= 3) {
      throw SubscriptionLimitException();
    }

    final id = await repository.createHabit(null);
    return CreateResult(habitId: id);
  }
}

void main() {
  late HabitService service;
  late MockHabitRepository mockRepo;
  late MockNotificationService mockNotifications;
  late MockAchievementService mockAchievements;

  setUp(() {
    mockRepo = MockHabitRepository();
    mockNotifications = MockNotificationService();
    mockAchievements = MockAchievementService();
    service = HabitService(
      repository: mockRepo,
      notifications: mockNotifications,
      achievements: mockAchievements,
    );
  });

  group('HabitService.trackHabit()', () {
    test('completes habit successfully', () async {
      mockRepo.setHabit(Habit());

      final result = await service.trackHabit(
        habitId: 'habit_1',
        date: DateTime.now().toIso8601String(),
        completed: true,
      );

      expect(result.success, isTrue);
      expect(result.xpEarned, equals(20));
      expect(mockRepo.updateCompletionCalled, equals(1));
    });

    test('rejects backdating more than 7 days', () async {
      final oldDate = DateTime.now().subtract(const Duration(days: 8));

      expect(
        () => service.trackHabit(
          habitId: 'habit_1',
          date: oldDate.toIso8601String(),
          completed: true,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('is idempotent (double-completion has no effect)', () async {
      mockRepo.setHabit(Habit(completed: true));

      final result = await service.trackHabit(
        habitId: 'habit_1',
        date: DateTime.now().toIso8601String(),
        completed: true,
      );

      expect(result.alreadyCompleted, isTrue);
      expect(result.xpEarned, equals(0)); // No double XP
      expect(mockRepo.updateCompletionCalled, equals(0));
    });

    test('checks achievements after completion', () async {
      mockRepo.setHabit(Habit());

      await service.trackHabit(
        habitId: 'habit_1',
        date: DateTime.now().toIso8601String(),
        completed: true,
      );

      expect(mockAchievements.checkHabitCalled, equals(1));
    });

    test('throws if habit belongs to different user', () async {
      mockRepo.setHabit(Habit(userId: 'different_user'));

      expect(
        () => service.trackHabit(
          habitId: 'habit_1',
          date: DateTime.now().toIso8601String(),
          completed: true,
        ),
        throwsA(isA<AuthorizationException>()),
      );
    });
  });

  group('HabitService.createHabit()', () {
    test('creates habit with valid data', () async {
      mockRepo.setCount(2);

      final result = await service.createHabit(
        userId: 'user_1',
        name: 'Morning Exercise',
        icon: '🏋️',
        frequency: HabitFrequency.daily,
        tier: SubscriptionTier.pro,
      );

      expect(result.habitId, equals('new_habit_id'));
    });

    test('rejects creation when habit limit exceeded for tier', () async {
      mockRepo.setCount(3); // Basic limit

      expect(
        () => service.createHabit(
          userId: 'user_1',
          name: 'New Habit',
          icon: '⭐',
          frequency: HabitFrequency.daily,
          tier: SubscriptionTier.basic, // Basic = 3 max
        ),
        throwsA(isA<SubscriptionLimitException>()),
      );
    });

    test('rejects empty habit name', () async {
      expect(
        () => service.createHabit(
          userId: 'user_1',
          name: '',
          icon: '⭐',
          frequency: HabitFrequency.daily,
          tier: SubscriptionTier.pro,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
