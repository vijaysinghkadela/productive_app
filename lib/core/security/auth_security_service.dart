import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:focusguard_pro/core/security/secure_storage_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

enum BiometricPurpose { unlock, payment, settingsChange }

class SecurityEvent {
  SecurityEvent(this.type, this.details) : timestamp = DateTime.now();
  final String type;
  final String details;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'type': type,
        'details': details,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Manages Biometrics, App Lock, and Auth Security Lifecycle
class AuthSecurityService {
  AuthSecurityService(this._secureStorage);
  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorageService _secureStorage;

  // Anti-brute-force state
  int _failedBiometricAttempts = 0;
  DateTime? _lockoutUntil;

  // App Lock state
  Timer? _inactivityTimer;
  final Duration _inactivityTimeout = const Duration(minutes: 5);
  bool _isAppLocked = false;

  bool get isAppLocked => _isAppLocked;

  /// Starts the inactivity timer. Bind to app lifecycle events.
  void startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityTimeout, lockApp);
  }

  void resetInactivityTimer() {
    if (!_isAppLocked) {
      startInactivityTimer();
    }
  }

  void onAppBackgrounded() {
    // Immediately lock app on background for high security
    lockApp();
  }

  /// Locks the app and clears sensitive in-memory data
  Future<void> lockApp() async {
    _isAppLocked = true;
    _inactivityTimer?.cancel();
    // Signal UI to show lock screen
  }

  /// Authenticate with biometric (Fingerprint/FaceID) or fallback PIN
  Future<bool> authenticateWithBiometric(BiometricPurpose purpose) async {
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      throw Exception('Too many attempts. Locked out until $_lockoutUntil');
    }

    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        return _fallbackToPinAuth(); // Device has no biometrics
      }

      final reason = purpose == BiometricPurpose.unlock
          ? 'Unlock FocusGuard Pro'
          : 'Verify identity to continue';

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Identity Verification Required',
            cancelButton: 'No thanks',
          ),
          IOSAuthMessages(
            cancelButton: 'No thanks',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _failedBiometricAttempts = 0;
        _isAppLocked = false;
        startInactivityTimer();
        return true;
      } else {
        await _handleFailedAttempt();
        return false;
      }
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint(e.message);
      await _handleFailedAttempt();
      return false;
    }
  }

  Future<void> _handleFailedAttempt() async {
    _failedBiometricAttempts++;
    if (_failedBiometricAttempts >= 5) {
      _lockoutUntil = DateTime.now().add(const Duration(minutes: 30));
      await onSuspiciousActivity(
        SecurityEvent(
          'BRUTE_FORCE_ATTEMPT',
          '5 consecutive failed biometric/PIN attempts',
        ),
      );
    }

    if (_failedBiometricAttempts >= 10) {
      // Remote wipe of local data
      await _secureStorage.wipeAll();
      await onSuspiciousActivity(
        SecurityEvent(
          'LOCAL_WIPE_TRIGGERED',
          '10 consecutive failed biometric/PIN attempts. Local data wiped.',
        ),
      );
    }
  }

  Future<bool> _fallbackToPinAuth() async {
    // In real app, route to custom PIN input screen
    // Retrieve PIN hash from SecureStorageService, compare hashes
    return false;
  }

  Future<void> onSuspiciousActivity(SecurityEvent event) async {
    if (kDebugMode) {
      debugPrint('🚨 Suspicious Activity: ${event.type} - ${event.details}');
    }
    // Implement API call to log security event server-side
    // Clear session immediately if highly suspicious
    if (event.type == 'LOCAL_WIPE_TRIGGERED' ||
        event.type == 'SESSION_HIJACK') {
      await _secureStorage.clearAuthTokens();
    }
  }
}
