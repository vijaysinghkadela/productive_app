import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

class SecureApiService {
  SecureApiService(this._clientHmacSecret);
  // In a real application, this secret should be securely obtained
  // post-authentication and stored in flutter_secure_storage.
  // NEVER hardcode this in client source code.
  final String _clientHmacSecret;

  /// Generates HMAC-SHA256 signature for API requests
  /// Prevents request tampering and replay attacks.
  String generateRequestSignature(
    String endpoint,
    String body,
    String nonce,
    String timestamp,
  ) {
    // Construct the signing string
    final signingString = '$timestamp.$nonce.$endpoint.$body';

    // Convert to bytes
    final key = utf8.encode(_clientHmacSecret);
    final bytes = utf8.encode(signingString);

    // Generate HMAC
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    return digest.toString();
  }

  /// Interceptor to automatically sign requests
  Interceptor get signingInterceptor => InterceptorsWrapper(
        onRequest: (options, handler) {
          final nonce = const Uuid().v4();
          final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

          final bodyString = options.data != null ? jsonEncode(options.data) : '';

          final signature = generateRequestSignature(
            options.path,
            bodyString,
            nonce,
            timestamp,
          );

          options.headers['X-Request-Signature'] = signature;
          options.headers['X-Request-Nonce'] = nonce;
          options.headers['X-Request-Timestamp'] = timestamp;

          handler.next(options);
        },
        onResponse: (response, handler) {
          validateResponseIntegrity(response);
          handler.next(response);
        },
      );

  /// Validates response integrity before processing to detect MITM or injection
  void validateResponseIntegrity(Response response) {
    if (response.data is Map<String, dynamic>) {
      // Basic check for unexpected fields (could be refined with strict schemas/Freezed)
      final data = response.data as Map<String, dynamic>;

      // If the API returns a signature, validate it here
      final serverSig = response.headers.value('X-Response-Signature');
      if (serverSig != null) {
        final bodyStr = jsonEncode(data);
        final timestamp = response.headers.value('X-Response-Timestamp') ?? '';
        final expected = _generateResponseSignature(bodyStr, timestamp);

        if (serverSig != expected) {
          throw Exception(
            'RESPONSE_INTEGRITY_FAILED: Invalid server signature',
          );
        }
      }
    }
  }

  String _generateResponseSignature(String body, String timestamp) {
    final signingString = '$timestamp.$body';
    final key = utf8.encode(_clientHmacSecret);
    final bytes = utf8.encode(signingString);
    final hmacSha256 = Hmac(sha256, key);
    return hmacSha256.convert(bytes).toString();
  }
}
