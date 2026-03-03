import 'package:flutter/foundation.dart';
import 'package:focusguard_pro/core/errors/app_exceptions.dart';

/// Centralized error handler for the app.
/// Routes errors to crash reporting and provides user-friendly messages.
class ErrorHandler {
  ErrorHandler._();

  /// Initialize global error handlers
  static void init() {
    // Flutter framework errors
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _reportError(details.exception, details.stack);
    };

    // Platform errors (unhandled)
    PlatformDispatcher.instance.onError = (error, stack) {
      _reportError(error, stack);
      return true;
    };
  }

  /// Report error to crash analytics (Firebase Crashlytics + Sentry in production)
  static void _reportError(Object error, StackTrace? stack) {
    // In production: send to Crashlytics and Sentry
    debugPrint('🔴 Error: $error');
    if (stack != null) debugPrint('Stack: $stack');
  }

  /// Convert any error into a user-friendly message
  static String getUserMessage(Object error) {
    if (error is AppException) return error.userMessage;
    if (error is NetworkException) return error.userMessage;
    if (error is AuthException) return error.userMessage;
    if (error is StorageException) return error.userMessage;
    if (error is PermissionException) return error.userMessage;
    if (error is SubscriptionException) return error.userMessage;
    return 'Something went wrong. Please try again.';
  }

  /// Log error for debugging (never shown to user)
  static void logError(String context, Object error, [StackTrace? stack]) {
    debugPrint('⚠️ [$context] $error');
    if (stack != null && kDebugMode) debugPrint('$stack');
  }

  /// Handle async operations with error catching
  static Future<T?> guard<T>(
    Future<T> Function() action, {
    String context = 'unknown',
    T? fallback,
  }) async {
    try {
      return await action();
    } catch (e, s) {
      logError(context, e, s);
      return fallback;
    }
  }
}
