import 'package:flutter/foundation.dart';

/// Analytics service abstraction.
/// In production: delegates to Firebase Analytics + custom events.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  /// Log screen view
  void logScreenView(String screenName) {
    debugPrint('📊 Screen: $screenName');
  }

  /// Log custom event
  void logEvent(String name, [Map<String, Object>? params]) {
    debugPrint('📊 Event: $name ${params ?? ''}');
  }

  /// Log feature usage
  void logFeatureUsed(String feature) =>
      logEvent('feature_used', {'feature': feature});

  /// Log paywall shown
  void logPaywallShown(String source) =>
      logEvent('paywall_shown', {'source': source});

  /// Log paywall conversion
  void logPaywallConverted(String plan) =>
      logEvent('paywall_converted', {'plan': plan});

  /// Log focus session
  void logFocusSession({
    required int durationMinutes,
    required String type,
    required bool completed,
  }) {
    logEvent('focus_session', {
      'duration_min': durationMinutes,
      'type': type,
      'completed': completed,
    });
  }

  /// Log achievement unlock
  void logAchievementUnlocked(String id) =>
      logEvent('achievement_unlocked', {'id': id});

  /// Log app block
  void logAppBlocked(String packageName) =>
      logEvent('app_blocked', {'package': packageName});

  /// Set user properties
  void setUserProperty(String name, String value) {
    debugPrint('📊 UserProperty: $name=$value');
  }

  /// Set user ID
  void setUserId(String userId) {
    debugPrint('📊 UserId: $userId');
  }
}
