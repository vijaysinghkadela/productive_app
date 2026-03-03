import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:freerasp/freerasp.dart';

class DeviceIntegrityResult {
  DeviceIntegrityResult({
    required this.isRootedOrJailbroken,
    required this.isEmulator,
    required this.isHooked,
    required this.isDebugged,
    this.isPlayIntegrityPassed = true,
    this.isAppAttestPassed = true,
  });

  factory DeviceIntegrityResult.fromChecks(List<dynamic> checks) =>
      DeviceIntegrityResult(
        isRootedOrJailbroken: checks.contains('root'),
        isEmulator: checks.contains('emulator'),
        isHooked: checks.contains('hook'),
        isDebugged: checks.contains('debug'),
      );
  final bool isRootedOrJailbroken;
  final bool isEmulator;
  final bool isHooked;
  final bool isDebugged;
  final bool isPlayIntegrityPassed;
  final bool isAppAttestPassed;

  bool get isCompromised =>
      isRootedOrJailbroken || isEmulator || isHooked || isDebugged;
}

/// Service to detect device integrity issues (Root, Jailbreak, Emulator, Hooks)
/// Implements enterprise-grade Runtime Application Self-Protection (RASP)
class DeviceIntegrityService {
  final List<String> _detectedThreats = [];

  bool get isCompromised => _detectedThreats.isNotEmpty;

  /// Initialize FreeRASP protections and other listeners
  Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('Skipping FreeRASP in debug mode to allow development.');
      return;
    }

    final config = TalsecConfig(
      androidConfig: AndroidConfig(
        packageName: 'app.focusguardpro.productive',
        signingCertHashes: ['YOUR_CERT_HASH_HERE'],
        supportedAlternativeStores: ['com.sec.android.app.samsungapps'],
      ),
      iosConfig: IOSConfig(
        bundleIds: ['app.focusguardpro.productive'],
        teamId: 'YOUR_TEAM_ID',
      ),
      watcherMail: 'security@focusguardpro.app',
      isProd: kReleaseMode,
    );

    final callback = ThreatCallback(
      onAppIntegrity: () => _handleThreat('App Integrity compromised'),
      onObfuscationIssues: () => _handleThreat('Obfuscation issues'),
      onDebug: () => _handleThreat('debug'),
      onDeviceBinding: () => _handleThreat('Device binding failed'),
      onDeviceID: () => _handleThreat('Device ID changed'),
      onHooks: () => _handleThreat('hook'),
      onPrivilegedAccess: () => _handleThreat('root'),
      onSecureHardwareNotAvailable: () =>
          _handleThreat('Secure Hardware not available'),
      onSimulator: () => _handleThreat('emulator'),
      onUnofficialStore: () => _handleThreat('Installed from unofficial store'),
    );

    Talsec.instance.attachListener(callback);
    await Talsec.instance.start(config);
  }

  void _handleThreat(String threat) {
    if (!_detectedThreats.contains(threat)) {
      _detectedThreats.add(threat);
      if (kDebugMode) {
        debugPrint('🚨 SECURITY THREAT DETECTED: $threat');
      }

      // Response to compromised device:
      // Level 1 (suspicious): log event, show security warning
      // Level 2 (likely compromised): disable sensitive features (strict mode PIN display, payment)
      // Level 3 (confirmed compromise): show security dialog, restrict to read-only mode
      // Never hard-exit the app (causes poor UX and bypass incentive) — use graceful degradation
    }
  }

  /// Perform a manual integrity check using combined sources
  Future<DeviceIntegrityResult> checkDeviceIntegrity() async {
    final checks = <String>[];

    // Check FreeRASP aggregated threats
    checks.addAll(_detectedThreats);

    // Apple DeviceCheck / App Attest (iOS):
    // Real implementation would use device_check plugin or similar
    final appAttestPassed = await _checkAppAttest();

    // Google Play Integrity API (Android):
    final playIntegrityPassed = await _checkPlayIntegrity();

    return DeviceIntegrityResult(
      isRootedOrJailbroken: checks.contains('root'),
      isEmulator: checks.contains('emulator'),
      isHooked: checks.contains('hook'),
      isDebugged: checks.contains('debug'),
      isPlayIntegrityPassed: playIntegrityPassed,
      isAppAttestPassed: appAttestPassed,
    );
  }

  Future<bool> _checkPlayIntegrity() async {
    if (!Platform.isAndroid) return true;
    // Call out to GCP / Play Integrity API validation here
    return true;
  }

  Future<bool> _checkAppAttest() async {
    if (!Platform.isIOS) return true;
    // Call out to DeviceCheck / App Attest here
    return true;
  }
}
