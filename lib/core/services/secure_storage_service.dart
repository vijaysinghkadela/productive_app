import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Manages AES-256 encryption keys via platform secure enclaves
/// (iOS Keychain / Android KeyStore) and provides encrypted Hive box access.
class SecureStorageService {
  static const _encryptionKeyName = 'focusguard_hive_encryption_key';

  static final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static HiveAesCipher? _cipher;

  /// Initialize the encryption cipher from secure enclave.
  /// Generates a new 256-bit key if none exists.
  static Future<void> init() async {
    final existingKey = await _secureStorage.read(key: _encryptionKeyName);
    Uint8List keyBytes;

    if (existingKey != null) {
      keyBytes = base64Url.decode(existingKey);
    } else {
      keyBytes = _generateKey();
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: base64Url.encode(keyBytes),
      );
    }

    _cipher = HiveAesCipher(keyBytes);
  }

  /// Returns the AES cipher for encrypting Hive boxes.
  static HiveAesCipher get cipher {
    if (_cipher == null) {
      throw StateError(
        'SecureStorageService not initialized. Call init() first.',
      );
    }
    return _cipher!;
  }

  /// Opens an encrypted Hive box.
  static Future<Box<T>> openEncryptedBox<T>(String name) async {
    return Hive.openBox<T>(name, encryptionCipher: cipher);
  }

  /// Store a sensitive value directly in secure enclave (for tokens, PINs).
  static Future<void> writeSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Read a sensitive value from secure enclave.
  static Future<String?> readSecure(String key) async {
    return _secureStorage.read(key: key);
  }

  /// Delete a sensitive value from secure enclave.
  static Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Wipe all secure storage (logout / data reset).
  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  /// Generate a cryptographically secure 256-bit key.
  static Uint8List _generateKey() {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(32, (_) => rng.nextInt(256)),
    );
  }
}
