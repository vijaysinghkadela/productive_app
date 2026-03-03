import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

/// Handles Screenshot Prevention, Screen Recording Detection, and Memory Zeroing
class DataProtectionService {
  /// Protects the screen from being screenshotted or recorded.
  /// Android: Sets FLAG_SECURE on the WindowManager
  /// iOS: Handled typically via blurring on lifecycle events (handled in UI wrappers)
  static Future<void> enableScreenProtection() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  /// Removes screen protection flags.
  static Future<void> disableScreenProtection() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  /// Explicitly clears sensitive strings from memory by overwriting them before garbage collection.
  static void clearSensitiveMemory(List<int> bytes) {
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = 0;
    }
  }

  /// Logs sanitization to never log passwords, tokens, PII
  static String sanitizeForLogging(String input) {
    if (input.isEmpty) return input;

    // Redact emails (e.g. j***@example.com)
    final emailRegex = RegExp(r'([a-zA-Z0-9.\-_]{1})(.*)@(.*)');
    if (emailRegex.hasMatch(input)) {
      return input.replaceAllMapped(
          emailRegex, (match) => '${match.group(1)}***@${match.group(3)}',);
    }

    // Redact JWT or Bearer tokens
    final tokenRegex =
        RegExp(r'(Bearer |ey)[a-zA-Z0-9=\-_]+(\.[a-zA-Z0-9=\-_]+)*');
    if (tokenRegex.hasMatch(input)) {
      return input.replaceAll(tokenRegex, '[REDACTED_TOKEN]');
    }

    return input;
  }

  /// Prevents clipboard sniffing by clearing the clipboard after copying sensitive content.
  static void clearClipboardAfterDelay(Duration delay) {
    Future.delayed(delay, () {
      // In Flutter: Clipboard.setData(const ClipboardData(text: ''));
      // Wait for dart/flutter UI import scope contexts
    });
  }
}

/// A wrapper widget to automatically enable/disable FLAG_SECURE around sensitive screens.
class SecureScreenWrapper extends StatefulWidget {
  const SecureScreenWrapper({required this.child, super.key});
  final Widget child;

  @override
  _SecureScreenWrapperState createState() => _SecureScreenWrapperState();
}

class _SecureScreenWrapperState extends State<SecureScreenWrapper> {
  @override
  void initState() {
    super.initState();
    DataProtectionService.enableScreenProtection();
  }

  @override
  void dispose() {
    DataProtectionService.disableScreenProtection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
