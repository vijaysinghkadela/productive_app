// ignore_for_file: discarded_futures
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/utils.dart';
import 'package:focusguard_pro/data/datasources/local_data_source.dart';
import 'package:focusguard_pro/domain/entities/focus_session.dart';

// ─── Timer Phase ───

enum TimerPhase { idle, work, breakTime, completed }

// ─── State ───

class FocusTimerState {
  const FocusTimerState({
    this.phase = TimerPhase.idle,
    this.isPaused = false,
    this.remainingSeconds = 0,
    this.totalWorkSeconds = 1500,
    this.totalBreakSeconds = 300,
    this.sessionType = 'Deep Work',
    this.ambientSound,
    this.currentSession,
    this.todaySessions = const [],
    this.completedPomodoros = 0,
    this.targetPomodoros = 4,
  });
  final TimerPhase phase;
  final bool isPaused;
  final int remainingSeconds;
  final int totalWorkSeconds;
  final int totalBreakSeconds;
  final String sessionType;
  final String? ambientSound;
  final FocusSession? currentSession;
  final List<FocusSession> todaySessions;
  final int completedPomodoros;
  final int targetPomodoros;

  FocusTimerState copyWith({
    TimerPhase? phase,
    bool? isPaused,
    int? remainingSeconds,
    int? totalWorkSeconds,
    int? totalBreakSeconds,
    String? sessionType,
    String? ambientSound,
    FocusSession? currentSession,
    List<FocusSession>? todaySessions,
    int? completedPomodoros,
    int? targetPomodoros,
  }) =>
      FocusTimerState(
        phase: phase ?? this.phase,
        isPaused: isPaused ?? this.isPaused,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
        totalWorkSeconds: totalWorkSeconds ?? this.totalWorkSeconds,
        totalBreakSeconds: totalBreakSeconds ?? this.totalBreakSeconds,
        sessionType: sessionType ?? this.sessionType,
        ambientSound: ambientSound ?? this.ambientSound,
        currentSession: currentSession ?? this.currentSession,
        todaySessions: todaySessions ?? this.todaySessions,
        completedPomodoros: completedPomodoros ?? this.completedPomodoros,
        targetPomodoros: targetPomodoros ?? this.targetPomodoros,
      );

  double get progress => phase == TimerPhase.idle
      ? 0.0
      : phase == TimerPhase.work
          ? 1.0 - (remainingSeconds / totalWorkSeconds).clamp(0.0, 1.0)
          : 1.0 - (remainingSeconds / totalBreakSeconds).clamp(0.0, 1.0);

  bool get isLongBreak => completedPomodoros > 0 && completedPomodoros % 4 == 0;
}

// ─── Notifier ───

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  FocusTimerNotifier(this._ds) : super(const FocusTimerState()) {
    _loadTodaySessions();
  }
  final LocalDataSource _ds;
  Timer? _timer;

  void _loadTodaySessions() {
    state = state.copyWith(
      todaySessions: _ds.getSessionsForDate(dayKey(DateTime.now())),
    );
  }

  void setPreset(int workMinutes, int breakMinutes) {
    state = state.copyWith(
      totalWorkSeconds: workMinutes * 60,
      totalBreakSeconds: breakMinutes * 60,
      remainingSeconds: workMinutes * 60,
    );
  }

  void setSessionType(String type) => state = state.copyWith(sessionType: type);

  void setAmbientSound(String? sound) =>
      state = state.copyWith(ambientSound: sound);

  /// Start a work phase. Creates a new session record.
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
      isPaused: false,
      remainingSeconds: state.totalWorkSeconds,
      currentSession: session,
    );
    _tick();
  }

  /// Start the break phase. Uses long break interval
  /// after every 4th completed pomodoro.
  void startBreak() {
    _timer?.cancel();
    final breakSeconds = state.isLongBreak
        ? state.totalBreakSeconds * 3 // 15min long break for 5min short
        : state.totalBreakSeconds;
    state = state.copyWith(
      phase: TimerPhase.breakTime,
      isPaused: false,
      remainingSeconds: breakSeconds,
    );
    _tick();
  }

  void _tick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 0) {
        _timer?.cancel();
        if (state.phase == TimerPhase.work) {
          _onWorkComplete();
        } else {
          _onBreakComplete();
        }
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  void _onWorkComplete() {
    state = state.copyWith(
      completedPomodoros: state.completedPomodoros + 1,
    );
    startBreak();
  }

  void _onBreakComplete() {
    _timer?.cancel();
    if (state.currentSession != null) {
      final completed = state.currentSession!.copyWith(
        endTime: DateTime.now(),
        completed: true,
      );
      _ds.saveSession(completed);
      _loadTodaySessions();
    }
    state = state.copyWith(
      phase: TimerPhase.completed,
      isPaused: false,
      remainingSeconds: 0,
    );
  }

  void stopSession() {
    _timer?.cancel();
    if (state.currentSession != null) {
      final stopped = state.currentSession!.copyWith(
        endTime: DateTime.now(),
        completed: false,
      );
      _ds.saveSession(stopped);
      _loadTodaySessions();
    }
    state = state.copyWith(
      phase: TimerPhase.idle,
      isPaused: false,
      remainingSeconds: 0,
    );
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      phase: TimerPhase.idle,
      isPaused: false,
      remainingSeconds: state.totalWorkSeconds,
      completedPomodoros: 0,
    );
  }

  /// Pause the active work/break countdown without resetting progress.
  void pause() {
    if (state.phase == TimerPhase.idle ||
        state.phase == TimerPhase.completed ||
        state.isPaused) {
      return;
    }
    _timer?.cancel();
    state = state.copyWith(isPaused: true);
  }

  /// Resume countdown from paused state.
  void resume() {
    if (!state.isPaused) return;
    state = state.copyWith(isPaused: false);
    _tick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ─── Provider (NOT autoDispose: timer must survive screen unmount) ───

final focusTimerProvider =
    StateNotifierProvider<FocusTimerNotifier, FocusTimerState>(
  (ref) => FocusTimerNotifier(ref.read(localDataSourceProvider)),
);

final localDataSourceProvider =
    Provider<LocalDataSource>((ref) => LocalDataSource());
