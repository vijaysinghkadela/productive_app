// ignore_for_file: join_return_with_assignment
import 'package:flutter/services.dart';

/// Service that bridges to native app blocker functionality.
///
/// Android: Uses UsageStatsManager via foreground service
/// iOS: Uses Screen Time API via Family Controls
class AppBlockerService {
  static const _channel = MethodChannel('com.focusguard/app_blocker');

  bool _isServiceRunning = false;
  bool get isServiceRunning => _isServiceRunning;

  final List<String> _blockedPackages = [];
  List<String> get blockedPackages => List.unmodifiable(_blockedPackages);

  /// Start the foreground blocking service.
  /// On Android, this launches a foreground service that polls the foreground app.
  /// On iOS, this sets up app shielding via Family Controls.
  Future<bool> startBlockingService(List<String> packageNames) async {
    try {
      _blockedPackages
        ..clear()
        ..addAll(packageNames);
      final result = await _channel.invokeMethod<bool>('startBlocking', {
        'packages': packageNames,
      });
      _isServiceRunning = result ?? false;
      return _isServiceRunning;
    } on PlatformException catch (e) {
      // Service not available on this platform or permission denied
      _isServiceRunning = false;
      throw AppBlockerException(
        'Failed to start blocking service: ${e.message}',
      );
    }
  }

  /// Stop the blocking service.
  Future<void> stopBlockingService() async {
    try {
      await _channel.invokeMethod('stopBlocking');
      _isServiceRunning = false;
      _blockedPackages.clear();
    } on PlatformException catch (e) {
      throw AppBlockerException(
        'Failed to stop blocking service: ${e.message}',
      );
    }
  }

  /// Update the list of blocked apps without restarting the service.
  Future<void> updateBlockedApps(List<String> packageNames) async {
    try {
      _blockedPackages
        ..clear()
        ..addAll(packageNames);
      await _channel.invokeMethod('updateBlockedApps', {
        'packages': packageNames,
      });
    } on PlatformException catch (e) {
      throw AppBlockerException('Failed to update blocked apps: ${e.message}');
    }
  }

  /// Check if the required permissions are granted.
  /// Android: PACKAGE_USAGE_STATS + SYSTEM_ALERT_WINDOW
  /// iOS: Family Controls authorization
  Future<bool> hasRequiredPermissions() async {
    try {
      return await _channel.invokeMethod<bool>('checkPermissions') ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Open the system settings page for usage access (Android) or
  /// Screen Time (iOS).
  Future<void> openPermissionSettings() async {
    try {
      await _channel.invokeMethod('openPermissionSettings');
    } on PlatformException {
      // Ignore — we can't always open settings
    }
  }

  /// Check if a specific app is currently in the foreground.
  Future<String?> getForegroundApp() async {
    try {
      return await _channel.invokeMethod<String>('getForegroundApp');
    } on PlatformException {
      return null;
    }
  }

  /// Enable strict mode (prevents disabling the blocker without a PIN).
  Future<void> enableStrictMode(String pin) async {
    try {
      await _channel.invokeMethod('enableStrictMode', {'pin': pin});
    } on PlatformException catch (e) {
      throw AppBlockerException('Failed to enable strict mode: ${e.message}');
    }
  }

  /// Disable strict mode with PIN verification.
  Future<bool> disableStrictMode(String pin) async {
    try {
      return await _channel
              .invokeMethod<bool>('disableStrictMode', {'pin': pin}) ??
          false;
    } on PlatformException {
      return false;
    }
  }
}

class AppBlockerException implements Exception {
  const AppBlockerException(this.message);
  final String message;

  @override
  String toString() => 'AppBlockerException: $message';
}
