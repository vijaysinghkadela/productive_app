import 'package:flutter/foundation.dart';

/// Crash reporting service abstraction.
/// In production: delegates to Firebase Crashlytics + Sentry.
class CrashReportingService {
  CrashReportingService._();
  static final CrashReportingService instance = CrashReportingService._();

  bool _initialized = false;

  /// Initialize crash reporting
  Future<void> init() async {
    if (_initialized) return;
    // In production: initialize Crashlytics + Sentry
    _initialized = true;
    debugPrint('🔴 Crash reporting initialized');
  }

  /// Log non-fatal error
  void recordError(Object error, StackTrace? stack, {String? reason}) {
    debugPrint('🔴 Non-fatal: $error${reason != null ? ' ($reason)' : ''}');
    // In production: Crashlytics.recordError + Sentry.captureException
  }

  /// Log message/breadcrumb
  void log(String message) {
    debugPrint('🔴 Log: $message');
    // In production: Crashlytics.log + Sentry.addBreadcrumb
  }

  /// Set user identifier for crash reports
  void setUserIdentifier(String userId) {
    debugPrint('🔴 User: $userId');
    // In production: Crashlytics.setUserIdentifier + Sentry.configureScope
  }

  /// Set custom key-value for crash context
  void setCustomKey(String key, String value) {
    debugPrint('🔴 Key: $key=$value');
  }

  /// Force a test crash (debug only)
  void testCrash() {
    if (kDebugMode) {
      throw StateError('Test crash from CrashReportingService');
    }
  }
}
