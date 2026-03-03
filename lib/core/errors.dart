/// Base failure class for domain layer errors
class AppFailure implements Exception {
  const AppFailure(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'AppFailure($code): $message';
}

class AuthFailure extends AppFailure {
  const AuthFailure(super.message, {super.code});
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class StorageFailure extends AppFailure {
  const StorageFailure([super.message = 'Local storage error']);
}

class PermissionFailure extends AppFailure {
  const PermissionFailure([super.message = 'Permission denied']);
}

class SubscriptionFailure extends AppFailure {
  const SubscriptionFailure([super.message = 'Subscription error']);
}

class UsageStatsFailure extends AppFailure {
  const UsageStatsFailure([super.message = 'Usage stats unavailable']);
}
