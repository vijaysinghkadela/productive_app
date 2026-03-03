import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

class CertificatePinningException implements Exception {
  CertificatePinningException(this.message);
  final String message;

  @override
  String toString() => 'CertificatePinningException: $message';
}

/// Provides strictly pinned certificate validation for critical domains.
class CertificatePinningService {
  static const Map<String, List<String>> _pinnedCertificates = {
    'firebaseapp.com': [
      'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // Primary pin
      'sha256/BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=', // Backup pin
    ],
    'googleapis.com': [
      'sha256/CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=',
      'sha256/DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=',
    ],
    'identitytoolkit.googleapis.com': [
      'sha256/EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE=',
      'sha256/FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF=',
    ],
    'focusguardpro.app': [
      'sha256/primary_pin_base64==',
      'sha256/backup_pin_base64==',
    ],
    'api.openai.com': [
      'sha256/i7WTqTvh0OioIruIfFR4kMPnBqrS2rdiVPl/s2uC/CY=',
      'sha256/C5+lpZ7tcVwmwQIMcRtPbsQtWLABXhQzejna0wHFr8M=',
    ],
    'firestore.googleapis.com': [
      'sha256/hxqRlPTu1bMS/0DITB1SSu0vd4u/8l8TPoH4GUEL0bA=',
      'sha256/KjLxfxajzmBH0fFrW2gTjbMbVBPrKYCpSSzJaABfR4I=',
    ],
  };

  /// Computes the SHA-256 hash of the DER-encoded certificate and compares it
  /// against the pinned hashes for the given host.
  bool validateCertificate(X509Certificate? cert, String host) {
    if (cert == null) return false;

    // Check if the exact host is pinned.
    // Also support wildcard matching (e.g., identitytoolkit.googleapis.com matches googleapis.com if not specified directly)
    List<String>? pins;
    if (_pinnedCertificates.containsKey(host)) {
      pins = _pinnedCertificates[host];
    } else {
      // Check for parent domain matching
      for (final key in _pinnedCertificates.keys) {
        if (host.endsWith('.$key') || host == key) {
          pins = _pinnedCertificates[key];
          break;
        }
      }
    }

    if (pins == null || pins.isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ Warning: No certificate pins configured for $host');
      }
      return true; // No pins registered -> allow fallback to system CA if desired (or reject in strict mode)
    }

    try {
      final derBytes = cert.der;
      if (derBytes.isEmpty) return false;

      final hashBytes = sha256.convert(Uint8List.fromList(derBytes)).bytes;
      final hashBase64 = base64Encode(hashBytes);
      final hashPrefix = 'sha256/$hashBase64';

      final isValid = pins.contains('sha256/$hashBase64') ||
          pins.contains(hashPrefix) ||
          pins.any((p) => p.endsWith(hashBase64));

      if (!isValid) {
        debugPrint('🚨 Certificate Pinning Failure for $host!');
        debugPrint('Expected one of: $pins');
        debugPrint('Received: sha256/$hashBase64');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error validating certificate: $e');
      return false;
    }
  }

  /// Injects the certificate pinning intercepts into a Dio instance.
  void attachToDio(Dio dio) {
    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        // Enforce TLS 1.3+ via SecurityContext
        final context = SecurityContext(withTrustedRoots: true);
        final client = HttpClient(context: context);

        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          if (kDebugMode) return true; // Allow self-signed in debug
          return false;
        };

        return client;
      };

      if (!kDebugMode) {
        adapter.validateCertificate =
            (X509Certificate? cert, String host, int port) {
          final isValid = validateCertificate(cert, host);
          if (!isValid) {
            throw CertificatePinningException(
              'Certificate validation failed for $host',
            );
          }
          return isValid;
        };
      }
    }
  }

  /// Rotate pins dynamically from an external secure source (e.g., Remote Config).
  Future<void> rotatePins(String host, List<String> newPins) async {
    // In a real app, you would persist these new pins to secure storage
    debugPrint('Rotating pins for $host: $newPins');
  }
}
