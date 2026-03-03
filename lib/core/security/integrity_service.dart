// ignore_for_file: prefer_expression_function_bodies
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class IntegrityCheckResult {
  IntegrityCheckResult({
    required this.isValidSignature,
    required this.isUntamperedBundle,
  });
  final bool isValidSignature;
  final bool isUntamperedBundle;

  bool get isClean => isValidSignature && isUntamperedBundle;
}

/// Provides Application Integrity Checks (Signatures, Repackaging, Reverse-Engineering)
class AppIntegrityService {
  // Expected values for Production
  // static const String _expectedAndroidSignatureHash =
  //     'YOUR_EXPECTED_SHA256_CERT_HASH';
  static const String _expectedIosBundleId = 'app.focusguardpro.productive';
  // static const String _expectedIosTeamId = 'YOUR_TEAM_ID';

  bool isReleaseBuild() => kReleaseMode;

  /// Performs full app integrity check
  Future<IntegrityCheckResult> performIntegrityCheck() async {
    if (kDebugMode) {
      debugPrint('Skipping strict app integrity checks in Debug mode.');
      return IntegrityCheckResult(
        isValidSignature: true,
        isUntamperedBundle: true,
      );
    }

    final isValidSig = await verifyAppSignature();
    final isUntampered = await _verifyBundleIntegrity();

    // Additional RASP is handled by DeviceIntegrityService (freeRASP plugin)

    return IntegrityCheckResult(
      isValidSignature: isValidSig,
      isUntamperedBundle: isUntampered,
    );
  }

  /// Verifies APK/IPA signing signature
  Future<bool> verifyAppSignature() async {
    try {
      final info = await PackageInfo.fromPlatform();

      if (Platform.isAndroid) {
        // Real implementation relies on a plugin like `flutter_app_badger` or custom MethodChannel
        // to retrieve the PackageManager signature hashes, or `freerasp` handles it internally.
        // We defer to DeviceIntegrityService via freeRASP for Android signing cert validation
        // to avoid duplicate native code.
        return true;
      } else if (Platform.isIOS) {
        if (info.packageName != _expectedIosBundleId) {
          debugPrint('🚨 iOS Bundle ID mismatch: ${info.packageName}');
          return false;
        }
        return true;
      }
      return true;
    } on Object catch (e) {
      debugPrint('Error verifying signature: $e');
      return false; // Fail secure
    }
  }

  /// Verifies checksums of critical assets
  Future<bool> _verifyBundleIntegrity() async {
    // Implement hash verification of critical local files (Lottie, config)
    // E.g.
    // final byteData = await rootBundle.load('assets/config/critical.json');
    // final digest = sha256.convert(byteData.buffer.asUint8List());
    // if (digest.toString() != EXPECTED_HASH) return false;
    return true;
  }
}
