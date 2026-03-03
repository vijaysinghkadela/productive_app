// ignore_for_file: avoid_positional_boolean_parameters, discarded_futures, unused_element
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/productivity_score.dart';
import 'package:focusguard_pro/core/utils.dart';
import 'package:focusguard_pro/data/datasources/local_data_source.dart';
import 'package:focusguard_pro/domain/entities/achievement.dart';
import 'package:focusguard_pro/domain/entities/app_info.dart';
import 'package:focusguard_pro/domain/entities/daily_stat.dart';
import 'package:focusguard_pro/domain/entities/focus_session.dart';
import 'package:focusguard_pro/domain/entities/goal.dart';
import 'package:focusguard_pro/domain/entities/user.dart';

// --- LocalDataSource Provider ---
final localDataSourceProvider =
    Provider<LocalDataSource>((ref) => LocalDataSource());

// --- Auth State ---
enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  const AuthState({this.status = AuthStatus.initial, this.user, this.error});
  final AuthStatus status;
  final UserEntity? user;
  final String? error;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void signIn(String email, String name) {
    state = AuthState(
      status: AuthStatus.authenticated,
      user: UserEntity(
        uid: 'local_user',
        email: email,
        displayName: name,
        tier: SubscriptionTier.pro, // Demo: give pro access
        streakDays: 5,
        lastActiveDate: DateTime.now(),
      ),
    );
  }

  void signOut() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void updateTier(SubscriptionTier tier) {
    if (state.user != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: state.user!.copyWith(tier: tier),
      );
    }
  }

  void updateStreak(int days) {
    if (state.user != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: state.user!.copyWith(streakDays: days),
      );
    }
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

// --- Focus Session State ---
enum TimerPhase { idle, work, breakTime, completed }

class FocusTimerState {
  const FocusTimerState({
    this.phase = TimerPhase.idle,
    this.remainingSeconds = 0,
    this.totalWorkSeconds = 1500,
    this.totalBreakSeconds = 300,
    this.sessionType = 'Deep Work',
    this.ambientSound,
    this.currentSession,
    this.todaySessions = const [],
  });
  final TimerPhase phase;
  final int remainingSeconds;
  final int totalWorkSeconds;
  final int totalBreakSeconds;
  final String sessionType;
  final String? ambientSound;
  final FocusSession? currentSession;
  final List<FocusSession> todaySessions;

  FocusTimerState copyWith({
    TimerPhase? phase,
    int? remainingSeconds,
    int? totalWorkSeconds,
    int? totalBreakSeconds,
    String? sessionType,
    String? ambientSound,
    FocusSession? currentSession,
    List<FocusSession>? todaySessions,
  }) =>
      FocusTimerState(
        phase: phase ?? this.phase,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        totalWorkSeconds: totalWorkSeconds ?? this.totalWorkSeconds,
        totalBreakSeconds: totalBreakSeconds ?? this.totalBreakSeconds,
        sessionType: sessionType ?? this.sessionType,
        ambientSound: ambientSound ?? this.ambientSound,
        currentSession: currentSession ?? this.currentSession,
        todaySessions: todaySessions ?? this.todaySessions,
      );
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  FocusTimerNotifier(this._dataSource) : super(const FocusTimerState()) {
    _loadTodaySessions();
  }
  final LocalDataSource _dataSource;
  Timer? _timer;

  void _loadTodaySessions() {
    final sessions = _dataSource.getSessionsForDate(dayKey(DateTime.now()));
    state = state.copyWith(todaySessions: sessions);
  }

  void setPreset(int workMinutes, int breakMinutes) {
    state = state.copyWith(
      totalWorkSeconds: workMinutes * 60,
      totalBreakSeconds: breakMinutes * 60,
      remainingSeconds: workMinutes * 60,
    );
  }

  void setSessionType(String type) {
    state = state.copyWith(sessionType: type);
  }

  void setAmbientSound(String? sound) {
    state = state.copyWith(ambientSound: sound);
  }

  void startWork() {
    _timer?.cancel();
    final session = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      workMinutes: state.totalWorkSeconds ~/ 60,
      breakMinutes: state.totalBreakSeconds ~/ 60,
      sessionType: state.sessionType,
      ambientSound: state.ambientSound,
    );
    state = state.copyWith(
      phase: TimerPhase.work,
      remainingSeconds: state.totalWorkSeconds,
      currentSession: session,
    );
    _startCountdown();
  }

  void startBreak() {
    _timer?.cancel();
    state = state.copyWith(
      phase: TimerPhase.breakTime,
      remainingSeconds: state.totalBreakSeconds,
    );
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 0) {
        timer.cancel();
        if (state.phase == TimerPhase.work) {
          // Work phase complete, start break
          _completeWorkPhase();
        } else {
          // Break complete
          _completeSession();
        }
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  void _completeWorkPhase() {
    state = state.copyWith(
      phase: TimerPhase.breakTime,
      remainingSeconds: state.totalBreakSeconds,
    );
    _startCountdown();
  }

  void _completeSession() {
    _timer?.cancel();
    if (state.currentSession != null) {
      final completed = state.currentSession!.copyWith(
        endTime: DateTime.now(),
        completed: true,
      );
      _dataSource.saveSession(completed);
      _loadTodaySessions();
    }
    state = state.copyWith(phase: TimerPhase.completed, remainingSeconds: 0);
  }

  void stopSession() {
    _timer?.cancel();
    if (state.currentSession != null) {
      final stopped = state.currentSession!.copyWith(
        endTime: DateTime.now(),
        completed: false,
      );
      _dataSource.saveSession(stopped);
      _loadTodaySessions();
    }
    state = state.copyWith(phase: TimerPhase.idle, remainingSeconds: 0);
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      phase: TimerPhase.idle,
      remainingSeconds: state.totalWorkSeconds,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>(
  (ref) => FocusTimerNotifier(ref.read(localDataSourceProvider)),
);

// --- Goals Provider ---
class GoalsNotifier extends StateNotifier<List<AppGoal>> {
  GoalsNotifier(this._dataSource) : super([]) {
    _load();
  }
  final LocalDataSource _dataSource;

  void _load() {
    state = _dataSource.getGoals();
  }

  Future<void> addGoal(AppGoal goal) async {
    await _dataSource.saveGoal(goal);
    _load();
  }

  Future<void> updateGoal(AppGoal goal) async {
    await _dataSource.saveGoal(goal);
    _load();
  }

  Future<void> removeGoal(String packageName) async {
    await _dataSource.deleteGoal(packageName);
    _load();
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, List<AppGoal>>(
  (ref) => GoalsNotifier(ref.read(localDataSourceProvider)),
);

// --- Blocker Provider ---
class BlockerNotifier extends StateNotifier<List<AppInfo>> {
  BlockerNotifier(this._dataSource) : super([]) {
    _load();
  }
  final LocalDataSource _dataSource;

  void _load() {
    state = _dataSource.getBlockedApps();
  }

  Future<void> toggleBlock(AppInfo app) async {
    final updated = app.copyWith(isBlocked: !app.isBlocked);
    if (updated.isBlocked) {
      await _dataSource.saveBlockedApp(updated);
    } else {
      await _dataSource.removeBlockedApp(updated.packageName);
    }
    _load();
  }

  Future<void> updateApp(AppInfo app) async {
    await _dataSource.saveBlockedApp(app);
    _load();
  }
}

final blockerProvider = StateNotifierProvider<BlockerNotifier, List<AppInfo>>(
  (ref) => BlockerNotifier(ref.read(localDataSourceProvider)),
);

// --- Daily Stats Provider ---
class DailyStatsNotifier extends StateNotifier<DailyStat?> {
  DailyStatsNotifier(this._dataSource) : super(null) {
    _loadToday();
  }
  final LocalDataSource _dataSource;

  void _loadToday() {
    state = _dataSource.getDailyStat(dayKey(DateTime.now()));
    state ??= DailyStat(date: dayKey(DateTime.now()));
  }

  Future<void> updateStat(DailyStat stat) async {
    await _dataSource.saveDailyStat(stat);
    state = stat;
  }

  List<DailyStat> getWeekStats() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 6));
    return _dataSource.getStatsForRange(start, end);
  }
}

final dailyStatsProvider =
    StateNotifierProvider<DailyStatsNotifier, DailyStat?>(
  (ref) => DailyStatsNotifier(ref.read(localDataSourceProvider)),
);

// --- Productivity Score Provider ---
final productivityScoreProvider = Provider<int>((ref) {
  final stat = ref.watch(dailyStatsProvider);
  if (stat == null) return 100;
  final goals = ref.watch(goalsProvider);
  final overGoal = goals.fold<int>(0, (sum, g) => sum + g.minutesOver);
  final auth = ref.watch(authProvider);
  return ProductivityScoreCalculator.calculate(
    overGoalMinutes: overGoal,
    completedSessions: stat.focusSessionsCompleted,
    goalsMet: stat.goalsCompleted,
    streakDays: auth.user?.streakDays ?? 0,
    socialMediaFreeDay: stat.socialMediaMinutes == 0,
  );
});

// --- Achievements Provider ---
class AchievementsNotifier extends StateNotifier<List<Achievement>> {
  AchievementsNotifier(this._dataSource) : super(defaultAchievements) {
    _load();
  }
  final LocalDataSource _dataSource;

  void _load() {
    state = defaultAchievements.map((a) {
      final progress = _dataSource.getAchievementProgress(a.id);
      if (progress != null) {
        return a.copyWith(
          currentValue: progress['currentValue'] as int? ?? 0,
          unlocked: progress['unlocked'] as bool? ?? false,
          unlockedDate: progress['unlockedDate'] != null
              ? DateTime.tryParse(progress['unlockedDate'] as String)
              : null,
        );
      }
      return a;
    }).toList();
  }

  Future<void> updateProgress(String id, int value) async {
    final idx = state.indexWhere((a) => a.id == id);
    if (idx == -1) return;
    final achievement = state[idx];
    final unlocked = value >= achievement.targetValue;
    final updated = achievement.copyWith(
      currentValue: value,
      unlocked: unlocked,
      unlockedDate: unlocked && !achievement.unlocked ? DateTime.now() : null,
    );
    await _dataSource.saveAchievement(updated);
    _load();
  }
}

final achievementsProvider =
    StateNotifierProvider<AchievementsNotifier, List<Achievement>>(
  (ref) => AchievementsNotifier(ref.read(localDataSourceProvider)),
);

// --- Settings Provider ---
class SettingsState {
  const SettingsState({
    this.notificationsEnabled = true,
    this.strictModeEnabled = false,
    this.strictModePin,
    this.bedtimeModeEnabled = false,
    this.bedtimeStart = const TimeOfDay(hour: 22, minute: 0),
    this.bedtimeEnd = const TimeOfDay(hour: 7, minute: 0),
    this.hasCompletedOnboarding = false,
    this.hasAcceptedTerms = false,
  });
  final bool notificationsEnabled;
  final bool strictModeEnabled;
  final String? strictModePin;
  final bool bedtimeModeEnabled;
  final TimeOfDay bedtimeStart;
  final TimeOfDay bedtimeEnd;
  final bool hasCompletedOnboarding;
  final bool hasAcceptedTerms;

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? strictModeEnabled,
    String? strictModePin,
    bool? bedtimeModeEnabled,
    TimeOfDay? bedtimeStart,
    TimeOfDay? bedtimeEnd,
    bool? hasCompletedOnboarding,
    bool? hasAcceptedTerms,
  }) =>
      SettingsState(
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        strictModeEnabled: strictModeEnabled ?? this.strictModeEnabled,
        strictModePin: strictModePin ?? this.strictModePin,
        bedtimeModeEnabled: bedtimeModeEnabled ?? this.bedtimeModeEnabled,
        bedtimeStart: bedtimeStart ?? this.bedtimeStart,
        bedtimeEnd: bedtimeEnd ?? this.bedtimeEnd,
        hasCompletedOnboarding:
            hasCompletedOnboarding ?? this.hasCompletedOnboarding,
        hasAcceptedTerms: hasAcceptedTerms ?? this.hasAcceptedTerms,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._dataSource) : super(const SettingsState()) {
    _load();
  }
  final LocalDataSource _dataSource;

  void _load() {
    state = state.copyWith(
      hasCompletedOnboarding: _dataSource.getHasCompletedOnboarding(),
      hasAcceptedTerms: _dataSource.getHasAcceptedTerms(),
    );
    // Load PIN asynchronously from secure enclave
    _loadSecurePin();
    final bedtime = _dataSource.getBedtimeConfig();
    if (bedtime != null) {
      state = state.copyWith(
        bedtimeModeEnabled: bedtime['enabled'] as bool? ?? false,
        bedtimeStart: TimeOfDay(
          hour: bedtime['startHour'] as int? ?? 22,
          minute: bedtime['startMinute'] as int? ?? 0,
        ),
        bedtimeEnd: TimeOfDay(
          hour: bedtime['endHour'] as int? ?? 7,
          minute: bedtime['endMinute'] as int? ?? 0,
        ),
      );
    }
  }

  Future<void> completeOnboarding() async {
    await _dataSource.setHasCompletedOnboarding();
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  Future<void> acceptTerms() async {
    await _dataSource.setHasAcceptedTerms();
    state = state.copyWith(hasAcceptedTerms: true);
  }

  Future<void> _loadSecurePin() async {
    final pin = await _dataSource.getStrictModePin();
    state = state.copyWith(
      strictModePin: pin,
      strictModeEnabled: pin != null,
    );
  }

  Future<void> setStrictModePin(String pin) async {
    await _dataSource.setStrictModePin(pin);
    state = state.copyWith(strictModePin: pin, strictModeEnabled: true);
  }

  Future<void> toggleNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> updateBedtime({
    bool? enabled,
    TimeOfDay? start,
    TimeOfDay? end,
  }) async {
    state = state.copyWith(
      bedtimeModeEnabled: enabled,
      bedtimeStart: start,
      bedtimeEnd: end,
    );
    await _dataSource.saveBedtimeConfig({
      'enabled': state.bedtimeModeEnabled,
      'startHour': state.bedtimeStart.hour,
      'startMinute': state.bedtimeStart.minute,
      'endHour': state.bedtimeEnd.hour,
      'endMinute': state.bedtimeEnd.minute,
    });
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(ref.read(localDataSourceProvider)),
);

// --- Installed Apps Provider (demo data) ---
final installedAppsProvider = Provider<List<AppInfo>>(
  (ref) => [
    const AppInfo(
      appName: 'Instagram',
      packageName: 'com.instagram.android',
      isSocialMedia: true,
      usageTodayMinutes: 45,
    ),
    const AppInfo(
      appName: 'TikTok',
      packageName: 'com.zhiliaoapp.musically',
      isSocialMedia: true,
      usageTodayMinutes: 30,
    ),
    const AppInfo(
      appName: 'YouTube',
      packageName: 'com.google.android.youtube',
      isSocialMedia: true,
      usageTodayMinutes: 60,
    ),
    const AppInfo(
      appName: 'Twitter / X',
      packageName: 'com.twitter.android',
      isSocialMedia: true,
      usageTodayMinutes: 20,
    ),
    const AppInfo(
      appName: 'Facebook',
      packageName: 'com.facebook.katana',
      isSocialMedia: true,
      usageTodayMinutes: 15,
    ),
    const AppInfo(
      appName: 'Snapchat',
      packageName: 'com.snapchat.android',
      isSocialMedia: true,
      usageTodayMinutes: 10,
    ),
    const AppInfo(
      appName: 'Reddit',
      packageName: 'com.reddit.frontpage',
      isSocialMedia: true,
      usageTodayMinutes: 25,
    ),
    const AppInfo(
      appName: 'Pinterest',
      packageName: 'com.pinterest',
      isSocialMedia: true,
      usageTodayMinutes: 5,
    ),
    const AppInfo(
      appName: 'WhatsApp',
      packageName: 'com.whatsapp',
      usageTodayMinutes: 40,
    ),
    const AppInfo(
      appName: 'Telegram',
      packageName: 'org.telegram.messenger',
      usageTodayMinutes: 15,
    ),
    const AppInfo(
      appName: 'Chrome',
      packageName: 'com.android.chrome',
      usageTodayMinutes: 35,
    ),
    const AppInfo(
      appName: 'Gmail',
      packageName: 'com.google.android.gm',
      usageTodayMinutes: 10,
    ),
    const AppInfo(
      appName: 'Netflix',
      packageName: 'com.netflix.mediaclient',
      usageTodayMinutes: 50,
    ),
    const AppInfo(
      appName: 'Spotify',
      packageName: 'com.spotify.music',
      usageTodayMinutes: 30,
    ),
    const AppInfo(
      appName: 'LinkedIn',
      packageName: 'com.linkedin.android',
      isSocialMedia: true,
      usageTodayMinutes: 8,
    ),
  ],
);

// --- Demo Weekly Stats ---
final weeklyStatsProvider = Provider<List<DailyStat>>((ref) {
  final now = DateTime.now();
  return List.generate(7, (i) {
    final date = now.subtract(Duration(days: 6 - i));
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return DailyStat(
      date: dateKey,
      appUsageMinutes: {
        'Instagram': 30 + (i * 5 % 40),
        'TikTok': 20 + (i * 3 % 30),
        'YouTube': 45 + (i * 7 % 50),
        'Twitter': 10 + (i * 2 % 20),
        'Facebook': 5 + (i * 4 % 15),
      },
      totalScreenTimeMinutes: 180 + (i * 20 % 120),
      socialMediaMinutes: 80 + (i * 10 % 60),
      focusSessionsCompleted: 2 + (i % 3),
      goalsCompleted: 1 + (i % 4),
      productivityScore: 55 + (i * 8 % 40),
    );
  });
});

// ====== NEW PROVIDERS FOR FOCUSGUARD PRO ======

// --- Habits Provider ---
class HabitsNotifier extends StateNotifier<List<_SimpleHabit>> {
  HabitsNotifier() : super([]);

  void addHabit(String name, String icon) {
    state = [
      ...state,
      _SimpleHabit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        icon: icon,
        completedDates: [],
        createdAt: DateTime.now(),
      ),
    ];
  }

  void toggleCompletion(String id) {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    state = state.map((h) {
      if (h.id == id) {
        final dates = List<String>.from(h.completedDates);
        if (dates.contains(todayStr)) {
          dates.remove(todayStr);
        } else {
          dates.add(todayStr);
        }
        return _SimpleHabit(
          id: h.id,
          name: h.name,
          icon: h.icon,
          currentStreak: dates.contains(todayStr)
              ? h.currentStreak + 1
              : (h.currentStreak - 1).clamp(0, 9999),
          completionRate: dates.length /
              (DateTime.now().difference(h.createdAt).inDays.clamp(1, 9999)),
          category: h.category,
          completedDates: dates,
          createdAt: h.createdAt,
        );
      }
      return h;
    }).toList();
  }
}

class _SimpleHabit {
  _SimpleHabit({
    required this.id,
    required this.name,
    required this.createdAt,
    this.icon = '🎯',
    this.currentStreak = 0,
    this.completionRate = 0.0,
    this.category = 'General',
    this.completedDates = const [],
  });
  final String id;
  final String name;
  final String icon;
  final int currentStreak;
  final double completionRate;
  final String category;
  final List<String> completedDates;
  final DateTime createdAt;

  bool get isCompletedToday {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return completedDates.contains(todayStr);
  }
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, List<_SimpleHabit>>(
  (ref) => HabitsNotifier(),
);

// --- Challenges Provider ---
class ChallengesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ChallengesNotifier() : super([]);
}

final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, List<Map<String, dynamic>>>(
  (ref) => ChallengesNotifier(),
);

// --- Journal Provider ---
class JournalNotifier extends StateNotifier<List<_SimpleJournalEntry>> {
  JournalNotifier() : super([]);

  void addEntry({
    String content = '',
    int mood = 3,
    int focusRating = 5,
    List<String> gratitude = const [],
  }) {
    state = [
      _SimpleJournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        content: content,
        mood: mood,
        focusRating: focusRating,
        gratitude: gratitude,
      ),
      ...state,
    ];
  }
}

class _SimpleJournalEntry {
  _SimpleJournalEntry({
    required this.id,
    required this.date,
    this.content = '',
    this.mood = 3,
    this.focusRating = 5,
    this.gratitude = const [],
    this.isPinned = false,
  });
  final String id;
  final DateTime date;
  final String content;
  final int mood;
  final int focusRating;
  final List<String> gratitude;
  final bool isPinned;

  String get moodEmoji {
    switch (mood) {
      case 1:
        return '😞';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😊';
      case 5:
        return '🤩';
      default:
        return '🙂';
    }
  }
}

final journalProvider =
    StateNotifierProvider<JournalNotifier, List<_SimpleJournalEntry>>(
  (ref) => JournalNotifier(),
);

// --- Rewards Provider ---
class _RewardState {
  const _RewardState({
    this.totalXp = 1250,
    this.level = 4,
    this.unlockedBadges = const ['First Focus', 'Week Warrior', 'Detox Day'],
    this.unlockedThemes = const ['default'],
    this.focusSessionsCompleted = 23,
    this.habitsCompleted = 12,
    this.challengesCompleted = 2,
    this.goalsAchieved = 8,
    this.loginStreak = 5,
  });
  final int totalXp;
  final int level;
  final List<String> unlockedBadges;
  final List<String> unlockedThemes;
  final int focusSessionsCompleted;
  final int habitsCompleted;
  final int challengesCompleted;
  final int goalsAchieved;
  final int loginStreak;
  int get xpForNextLevel => (100 * level * 1.3).toInt();

  double get levelProgress {
    var total = 0;
    for (var i = 1; i < level; i++) {
      total += (100 * i * 1.3).toInt();
    }
    final xpInLevel = totalXp - total;
    return (xpInLevel / xpForNextLevel).clamp(0.0, 1.0);
  }

  String get levelTitle {
    if (level >= 50) return 'Focus God';
    if (level >= 40) return 'Legend';
    if (level >= 30) return 'Master';
    if (level >= 20) return 'Expert';
    if (level >= 15) return 'Veteran';
    if (level >= 10) return 'Adept';
    if (level >= 5) return 'Apprentice';
    return 'Novice';
  }
}

final rewardsProvider = Provider<_RewardState>((ref) => const _RewardState());
