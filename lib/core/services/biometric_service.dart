import 'package:flutter/services.dart';

/// Biometric authentication service.
/// In production: delegates to local_auth package.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  /// Check if device supports biometric auth
  Future<bool> isAvailable() async {
    // In production: LocalAuthentication().canCheckBiometrics
    try {
      return true; // Demo always available
    } on PlatformException {
      return false;
    }
  }

  /// Authenticate with biometrics
  /// Returns true if authenticated successfully
  Future<bool> authenticate(
      {String reason = 'Authenticate to continue'}) async {
    // In production: LocalAuthentication().authenticate(localizedReason: reason)
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return true; // Demo always succeeds
    } on PlatformException {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableTypes() async {
    // In production: LocalAuthentication().getAvailableBiometrics()
    return [BiometricType.fingerprint, BiometricType.face];
  }
}

/// Biometric types supported
enum BiometricType { fingerprint, face, iris }
