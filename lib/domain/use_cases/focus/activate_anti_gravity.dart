import 'package:focusguard_pro/core/errors/failure.dart';
import 'package:focusguard_pro/data/models/feature_models.dart';
import 'package:focusguard_pro/domain/repositories/repositories.dart';

/// Validates whether Anti-Gravity mode can be activated for the active session.
class ActivateAntiGravityUseCase {
  /// Creates an Anti-Gravity activation use case.
  ActivateAntiGravityUseCase(
    this._subscriptionRepository,
    this._focusSessionRepository, {
    this.requiredElapsedMinutes = 30,
  });

  final SubscriptionRepository _subscriptionRepository;
  final FocusSessionRepository _focusSessionRepository;
  final int requiredElapsedMinutes;

  /// Returns `Success(true)` when all activation constraints are satisfied.
  ///
  /// Constraints:
  /// - User tier must be `elite`
  /// - Focus session must be active
  /// - Elapsed focus minutes must be greater than or equal to threshold
  Future<Result<bool>> execute() async {
    final subscriptionResult = await _subscriptionRepository.getSubscription();

    if (subscriptionResult is Failure<SubscriptionModel>) {
      final failure = subscriptionResult;
      return Failure<bool>(
        failure.message,
        code: failure.code ?? 'subscription_fetch_failed',
      );
    }

    final subscription =
        (subscriptionResult as Success<SubscriptionModel>).value;
    final tier = subscription.tier.toLowerCase();
    if (tier != 'elite') {
      return const Failure<bool>(
        'Anti-Gravity mode requires Elite tier.',
        code: 'tier_not_eligible',
      );
    }

    final sessionResult = await _focusSessionRepository.getSessionStatus();
    if (sessionResult is Failure<FocusSessionStatus>) {
      final failure = sessionResult;
      return Failure<bool>(
        failure.message,
        code: failure.code ?? 'session_status_unavailable',
      );
    }

    final sessionStatus = (sessionResult as Success<FocusSessionStatus>).value;

    if (!sessionStatus.sessionActive) {
      return const Failure<bool>(
        'Focus session is not active.',
        code: 'session_inactive',
      );
    }

    if (sessionStatus.elapsedMinutes < requiredElapsedMinutes) {
      return Failure<bool>(
        'Anti-Gravity unlocks after $requiredElapsedMinutes focused minutes.',
        code: 'insufficient_focus_time',
      );
    }

    return const Success<bool>(true);
  }
}
