import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptedData {
  EncryptedData({required this.ciphertext, required this.iv});

  factory EncryptedData.fromJson(Map<String, dynamic> json) => EncryptedData(
        ciphertext: json['ciphertext'] as String,
        iv: json['iv'] as String,
      );
  final String ciphertext;
  final String iv;

  Map<String, dynamic> toJson() => {
        'ciphertext': ciphertext,
        'iv': iv,
      };
}

/// Provides AES-256-GCM encryption with keys derived from a Hardware-Backed Master Key (Keystore/Secure Enclave).
class EncryptionService {
  EncryptionService(this._secureStorage);
  final FlutterSecureStorage _secureStorage;
  static const String _masterKeyAlias = 'com.focusguardpro.masterKey';

  encrypt.Key? _masterKey;

  /// Initializes the master key, creating a new Cryptographically Secure Pseudo-Random (CSPRNG) one if absent.
  Future<void> initialize() async {
    final existingKey = await _secureStorage.read(key: _masterKeyAlias);
    if (existingKey == null) {
      final newKey = encrypt.Key.fromSecureRandom(32); // 256 bits
      await _secureStorage.write(key: _masterKeyAlias, value: newKey.base64);
      _masterKey = newKey;
    } else {
      _masterKey = encrypt.Key.fromBase64(existingKey);
    }
  }

  /// Encrypts plaintext using AES-GCM with a random IV.
  Future<EncryptedData> encryptData(
    String plaintext, {
    String? contextContext,
  }) async {
    if (_masterKey == null) await initialize();

    // Derive a unique key for the context if provided to isolate data domains
    final key = contextContext != null
        ? _deriveKey(_masterKey!, contextContext)
        : _masterKey!;

    final iv = encrypt.IV
        .fromSecureRandom(12); // GCM standard IV size is 96 bits (12 bytes)
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));

    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    return EncryptedData(
      ciphertext: encrypted.base64,
      iv: iv.base64,
    );
  }

  /// Decrypts AES-GCM encrypted data.
  Future<String> decryptData(
    EncryptedData data, {
    String? contextContext,
  }) async {
    if (_masterKey == null) await initialize();

    final key = contextContext != null
        ? _deriveKey(_masterKey!, contextContext)
        : _masterKey!;

    final iv = encrypt.IV.fromBase64(data.iv);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.gcm));

    final encrypted = encrypt.Encrypted.fromBase64(data.ciphertext);
    return encrypter.decrypt(encrypted, iv: iv);
  }

  /// Derives an isolation key from the Master Key + context label using SHA-256
  encrypt.Key _deriveKey(encrypt.Key masterKey, String context) {
    final bytes = utf8.encode(context);
    final hmac = Hmac(sha256, masterKey.bytes);
    final digest = hmac.convert(bytes);
    return encrypt.Key(Uint8List.fromList(digest.bytes));
  }

  /// Rotates the Master Key, requiring re-encryption of all data using it.
  Future<void> rotateMasterKey() async {
    final newKey = encrypt.Key.fromSecureRandom(32);
    // In a real implementation:
    // 1. Load all encrypted data using _masterKey
    // 2. Decrypt it
    // 3. Encrypt with newKey
    // 4. Save new data
    await _secureStorage.write(key: _masterKeyAlias, value: newKey.base64);
    _masterKey = newKey;
  }
}
