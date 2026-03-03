// ignore_for_file: avoid_positional_boolean_parameters, discarded_futures
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/errors/failure.dart';
import 'package:focusguard_pro/data/models/feature_models.dart';
import 'package:focusguard_pro/domain/entities/user.dart';
import 'package:focusguard_pro/domain/repositories/repositories.dart';
import 'package:focusguard_pro/domain/use_cases/focus/activate_anti_gravity.dart';
import 'package:focusguard_pro/presentation/providers/app_providers.dart'
    hide FocusTimerState, TimerPhase, focusTimerProvider;
import 'package:focusguard_pro/presentation/providers/focus_timer_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Reactive state for Anti-Gravity mode.
class AntiGravityState {
  /// Creates immutable Anti-Gravity UI state.
  const AntiGravityState({
    this.isActive = false,
    this.tiltX = 0,
    this.tiltY = 0,
    this.elapsedMinutes = 0,
  });

  final bool isActive;
  final double tiltX;
  final double tiltY;
  final int elapsedMinutes;

  /// Creates a modified state while preserving unchanged fields.
  AntiGravityState copyWith({
    bool? isActive,
    double? tiltX,
    double? tiltY,
    int? elapsedMinutes,
  }) =>
      AntiGravityState(
        isActive: isActive ?? this.isActive,
        tiltX: tiltX ?? this.tiltX,
        tiltY: tiltY ?? this.tiltY,
        elapsedMinutes: elapsedMinutes ?? this.elapsedMinutes,
      );
}

/// Current authenticated user's subscription tier.
final currentSubscriptionTierProvider = Provider<SubscriptionTier>((Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.tier ?? SubscriptionTier.free;
});

/// Derived focus-session status used by Anti-Gravity activation logic.
final focusSessionStatusProvider = Provider<FocusSessionStatus>((Ref ref) {
  final timerState = ref.watch(focusTimerProvider);
  final isSessionActive =
      timerState.phase == TimerPhase.work && !timerState.isPaused;
  final rawElapsedSeconds =
      timerState.totalWorkSeconds - timerState.remainingSeconds;
  final elapsedSeconds = rawElapsedSeconds < 0
      ? 0
      : rawElapsedSeconds > timerState.totalWorkSeconds
          ? timerState.totalWorkSeconds
          : rawElapsedSeconds;

  return FocusSessionStatus(
    elapsedMinutes: elapsedSeconds ~/ 60,
    sessionActive: isSessionActive,
  );
});

/// Elapsed focus minutes during an active work phase.
final focusElapsedMinutesProvider = Provider<int>((Ref ref) {
  final status = ref.watch(focusSessionStatusProvider);
  return status.elapsedMinutes;
});

/// Whether the current focus session is in active work phase.
final focusSessionActiveProvider = Provider<bool>((Ref ref) {
  final status = ref.watch(focusSessionStatusProvider);
  return status.sessionActive;
});

/// Broadcast token incremented to trigger "snap to origin" in all floating cards.
final antiGravitySnapTriggerProvider = StateProvider<int>((Ref ref) => 0);

final Provider<SubscriptionRepository>
    antiGravitySubscriptionRepositoryProvider =
    Provider<SubscriptionRepository>(
  _ProviderBackedSubscriptionRepository.new,
);

final Provider<FocusSessionRepository>
    antiGravityFocusSessionRepositoryProvider =
    Provider<FocusSessionRepository>(
  _ProviderBackedFocusSessionRepository.new,
);

/// Dependency-injected use case for Anti-Gravity activation decisions.
final activateAntiGravityUseCaseProvider = Provider<ActivateAntiGravityUseCase>(
  (Ref ref) => ActivateAntiGravityUseCase(
    ref.read(antiGravitySubscriptionRepositoryProvider),
    ref.read(antiGravityFocusSessionRepositoryProvider),
  ),
);

/// Anti-Gravity state provider.
final antiGravityProvider =
    StateNotifierProvider.autoDispose<AntiGravityNotifier, AntiGravityState>(
  (Ref ref) {
    final notifier =
        AntiGravityNotifier(ref.read(activateAntiGravityUseCaseProvider));

    ref.listen<int>(focusElapsedMinutesProvider, (
      int? previous,
      int next,
    ) {
      if (previous == next) return;
      notifier.onElapsedMinuteTick(next);
    });

    ref.listen<bool>(focusSessionActiveProvider, (
      bool? previous,
      bool next,
    ) {
      if (previous == next) return;
      notifier.onSessionActivityChanged(next);
    });

    ref.listen<SubscriptionTier>(currentSubscriptionTierProvider, (
      SubscriptionTier? previous,
      SubscriptionTier next,
    ) {
      if (previous == next) return;
      unawaited(notifier.evaluateActivation());
    });

    notifier.onElapsedMinuteTick(
      ref.read(focusElapsedMinutesProvider),
      evaluate: false,
    );
    notifier.onSessionActivityChanged(
      ref.read(focusSessionActiveProvider),
      evaluate: false,
    );
    unawaited(notifier.evaluateActivation());

    return notifier;
  },
);

/// Coordinates Anti-Gravity activation and tilt updates.
class AntiGravityNotifier extends StateNotifier<AntiGravityState> {
  /// Creates Anti-Gravity notifier.
  AntiGravityNotifier(this._activateAntiGravityUseCase)
      : super(const AntiGravityState());

  static const Duration _sensorThrottle = Duration(milliseconds: 33);
  static const double _earthGravity = 9.81;

  final ActivateAntiGravityUseCase _activateAntiGravityUseCase;
  StreamSubscription<AccelerometerEvent>? _sensorSubscription;
  DateTime _lastSensorUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  bool _isEvaluating = false;

  /// Handles focus elapsed-minute changes.
  void onElapsedMinuteTick(int elapsedMinutes, {bool evaluate = true}) {
    state = state.copyWith(elapsedMinutes: elapsedMinutes);
    if (evaluate) {
      unawaited(evaluateActivation());
    }
  }

  /// Handles session active/inactive state transitions.
  void onSessionActivityChanged(bool sessionActive, {bool evaluate = true}) {
    if (!sessionActive) {
      _deactivate();
    }
    if (evaluate) {
      unawaited(evaluateActivation());
    }
  }

  /// Evaluates anti-gravity activation condition and updates sensor lifecycle.
  Future<void> evaluateActivation() async {
    if (_isEvaluating) return;
    _isEvaluating = true;
    final result = await _activateAntiGravityUseCase.execute();
    _isEvaluating = false;

    result.when(
      success: (_) => _activate(),
      failure: (_, __) => _deactivate(),
    );
  }

  void _activate() {
    if (state.isActive) return;
    state = state.copyWith(isActive: true);
    _resumeSensorStream();
  }

  void _deactivate() {
    if (!state.isActive && state.tiltX == 0 && state.tiltY == 0) {
      _pauseSensorStream();
      return;
    }
    state = state.copyWith(isActive: false, tiltX: 0, tiltY: 0);
    _pauseSensorStream();
  }

  void _resumeSensorStream() {
    if (_sensorSubscription != null) return;

    _sensorSubscription = accelerometerEventStream().listen(
      _onAccelerometerEvent,
      onError: (_, __) {},
      cancelOnError: false,
    );
  }

  void _pauseSensorStream() {
    _sensorSubscription?.cancel();
    _sensorSubscription = null;
    _lastSensorUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    if (!state.isActive) return;

    final now = DateTime.now();
    if (now.difference(_lastSensorUpdate) < _sensorThrottle) return;
    _lastSensorUpdate = now;

    final nextTiltX = _normalizeAxis(event.x);
    final nextTiltY = _normalizeAxis(event.y);
    if ((nextTiltX - state.tiltX).abs() < 0.0001 &&
        (nextTiltY - state.tiltY).abs() < 0.0001) {
      return;
    }

    state = state.copyWith(tiltX: nextTiltX, tiltY: nextTiltY);
  }

  double _normalizeAxis(double rawValue) {
    final normalized = rawValue / _earthGravity;
    if (normalized > 1) return 1;
    if (normalized < -1) return -1;
    return normalized;
  }

  @override
  void dispose() {
    _pauseSensorStream();
    super.dispose();
  }
}

class _ProviderBackedSubscriptionRepository implements SubscriptionRepository {
  _ProviderBackedSubscriptionRepository(this._ref);

  final Ref _ref;

  @override
  Future<Result<SubscriptionModel>> getSubscription() async {
    final authState = _ref.read(authProvider);
    final tier = authState.user?.tier ?? SubscriptionTier.free;
    final userId = authState.user?.uid ?? 'local_user';

    return Success<SubscriptionModel>(
      SubscriptionModel(
        userId: userId,
        tier: _tierToString(tier),
      ),
    );
  }

  @override
  Future<Result<SubscriptionModel>> purchase(String productId) async =>
      const Failure<SubscriptionModel>(
        'Purchase is unavailable in anti-gravity provider context.',
        code: 'unsupported_operation',
      );

  @override
  Future<Result<SubscriptionModel>> restorePurchases() async =>
      const Failure<SubscriptionModel>(
        'Restore purchases is unavailable in anti-gravity provider context.',
        code: 'unsupported_operation',
      );

  @override
  Future<Result<bool>> checkFeatureAccess(String feature) async {
    final tier = _ref.read(currentSubscriptionTierProvider);
    if (feature == 'antiGravityMode') {
      return Success<bool>(tier == SubscriptionTier.elite);
    }
    return const Success<bool>(true);
  }

  String _tierToString(SubscriptionTier tier) => switch (tier) {
        SubscriptionTier.free => 'free',
        SubscriptionTier.basic => 'basic',
        SubscriptionTier.pro => 'pro',
        SubscriptionTier.elite => 'elite',
      };
}

class _ProviderBackedFocusSessionRepository implements FocusSessionRepository {
  _ProviderBackedFocusSessionRepository(this._ref);

  final Ref _ref;

  @override
  Future<Result<FocusSessionStatus>> getSessionStatus() async =>
      Success<FocusSessionStatus>(_ref.read(focusSessionStatusProvider));
}
