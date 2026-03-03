/// Typed exceptions for the app domain layer.
/// Each exception includes a user-friendly message and optional error code.
library;

class AppException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;

  const AppException(this.message, {this.code, this.originalError});

  String get userMessage => message;

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Please check your network.',
    this.statusCode,
  ]);
  final int? statusCode;

  @override
  String get userMessage {
    if (statusCode == 401) return 'Session expired. Please sign in again.';
    if (statusCode == 403) return 'Access denied.';
    if (statusCode == 429) return 'Too many requests. Please wait a moment.';
    if (statusCode != null && statusCode! >= 500) {
      return 'Server error. Please try again later.';
    }
    return message;
  }
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed.', String? code])
      : super(code: code);

  @override
  String get userMessage {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return message;
    }
  }
}

class StorageException extends AppException {
  const StorageException([super.message = 'Failed to save data locally.']);
}

class PermissionException extends AppException {
  const PermissionException(
      [super.message = 'Permission required.', String? permission])
      : super(code: permission);

  @override
  String get userMessage {
    switch (code) {
      case 'usage_stats':
        return 'Usage access permission is required to track app usage.';
      case 'overlay':
        return 'Display over other apps permission is needed to block apps.';
      case 'notification':
        return 'Notification permission is needed for reminders.';
      case 'biometric':
        return 'Biometric authentication is required for strict mode.';
      default:
        return message;
    }
  }
}

class SubscriptionException extends AppException {
  const SubscriptionException([super.message = 'Subscription error.']);
}

class AiCoachingException extends AppException {
  const AiCoachingException(
      [super.message = 'AI coaching is temporarily unavailable.']);
}

class RateLimitException extends AppException {
  const RateLimitException(
      [super.message = 'You\'ve reached your limit. Upgrade for more.']);
}
