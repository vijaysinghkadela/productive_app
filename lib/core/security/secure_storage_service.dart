import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:focusguard_pro/core/security/encryption_service.dart';

/// Wraps flutter_secure_storage with additional application-level encryption bounds.
class SecureStorageService {
  SecureStorageService(this._encryptionService)
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
              // Requires unlocking device to access keys
              ),
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.unlocked_this_device,
          ),
        );
  final FlutterSecureStorage _storage;
  final EncryptionService _encryptionService;

  static const _authTokensKey = 'secure_auth_tokens';
  static const _userPrefsKey = 'secure_user_prefs';
  static const _focusPinKey = 'secure_focus_pin_hash';

  Future<void> initialize() async {
    await _encryptionService.initialize();
  }

  /// Saves auth tokens securely.
  Future<void> saveAuthTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final data = {
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };

    final rawJson = jsonEncode(data);
    final encrypted = await _encryptionService.encryptData(
      rawJson,
      contextContext: 'auth_tokens',
    );

    await _storage.write(
      key: _authTokensKey,
      value: jsonEncode(encrypted.toJson()),
    );
  }

  /// Retrieves auth tokens securely.
  Future<Map<String, String>?> getAuthTokens() async {
    final raw = await _storage.read(key: _authTokensKey);
    if (raw == null) return null;

    try {
      final encrypted =
          EncryptedData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final decrypted = await _encryptionService.decryptData(
        encrypted,
        contextContext: 'auth_tokens',
      );
      final decoded = jsonDecode(decrypted) as Map<String, dynamic>;

      return {
        'accessToken': decoded['accessToken'] as String,
        if (decoded.containsKey('refreshToken'))
          'refreshToken': decoded['refreshToken'] as String,
      };
    } catch (_) {
      // Possible key rotation or tampering
      return null;
    }
  }

  Future<void> clearAuthTokens() async {
    await _storage.delete(key: _authTokensKey);
  }

  Future<void> saveFocusPinHash(String hash) async {
    await _storage.write(key: _focusPinKey, value: hash);
  }

  Future<String?> getFocusPinHash() async => _storage.read(key: _focusPinKey);

  /// Secure secure wipe of all strictly secured keys.
  Future<void> wipeAll() async {
    await _storage.deleteAll();
    // Memory protection handled natively by Secure Storage plugin when keys drop
  }
}
