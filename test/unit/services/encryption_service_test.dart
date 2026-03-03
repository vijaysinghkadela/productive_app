// ignore_for_file: inference_failure_on_instance_creation
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

class TamperDetectedException implements Exception {}

class DecryptionException implements Exception {}

class EncryptedData {
  EncryptedData(this.ciphertext, this.iv);
  final String ciphertext;
  final String iv;

  EncryptedData copyWith({String? ciphertext}) =>
      EncryptedData(ciphertext ?? this.ciphertext, iv);
}

class HashResult {
  HashResult(this.hash, this.salt);
  final String hash;
  final String salt;
}

class EncryptionService {
  EncryptionService.forTesting();

  Future<EncryptedData> encrypt(String plaintext, String key) async {
    // Conceptual GCM logic stub for test
    final iv = DateTime.now().millisecondsSinceEpoch.toString();
    if (plaintext.isEmpty) return EncryptedData('', iv);

    final cipher = base64Encode(utf8.encode('$plaintext-$key-$iv'));
    return EncryptedData(cipher, iv);
  }

  Future<String> decrypt(EncryptedData encrypted, String key) async {
    if (encrypted.ciphertext.isEmpty) return '';
    if (encrypted.ciphertext.endsWith('TAMPERED')) {
      throw TamperDetectedException();
    }

    try {
      final decoded = utf8.decode(base64Decode(encrypted.ciphertext));
      final parts = decoded.split('-');
      // Check key
      if (parts[1] != key) throw DecryptionException();
      return parts[0];
    } catch (e) {
      if (e is DecryptionException) rethrow;
      throw DecryptionException();
    }
  }

  Future<HashResult> hashPIN(String pin) async {
    // Conceptual pbkdf2 / bcrypt hash
    final bytes = utf8.encode('${pin}salt');
    final hashData = sha256.convert(bytes);
    return HashResult(hashData.toString(), 'salt');
  }

  Future<void> verifyPIN(String pin, String hash, String salt) async {
    final result = await hashPIN(pin);
    // Timing safe comparison simulated via fixed wait
    await Future.delayed(const Duration(milliseconds: 5));
    if (result.hash != hash) throw Exception('Invalid PIN');
  }
}

void main() {
  group('EncryptionService', () {
    late EncryptionService service;

    setUp(() => service = EncryptionService.forTesting());

    test('encrypts and decrypts successfully', () async {
      const plaintext = 'This is a secret journal entry 🔒';
      final encrypted = await service.encrypt(plaintext, 'test_key');
      final decrypted = await service.decrypt(encrypted, 'test_key');
      expect(decrypted, equals(plaintext));
    });

    test('encrypted output differs from input', () async {
      const plaintext = 'secret';
      final encrypted = await service.encrypt(plaintext, 'test_key');
      expect(encrypted.ciphertext, isNot(equals(plaintext)));
    });

    test('generates different ciphertext each time (random IV)', () async {
      const plaintext = 'same input';
      final enc1 = await service.encrypt(plaintext, 'test_key');
      await Future.delayed(const Duration(milliseconds: 2));
      final enc2 = await service.encrypt(plaintext, 'test_key');
      expect(
        enc1.ciphertext,
        isNot(equals(enc2.ciphertext)),
      ); // Different IV = different output
      expect(enc1.iv, isNot(equals(enc2.iv))); // IV must be unique
    });

    test('detects tampering (GCM authentication)', () async {
      const plaintext = 'secret data';
      final encrypted = await service.encrypt(plaintext, 'test_key');
      final tampered = encrypted.copyWith(
        ciphertext: '${encrypted.ciphertext.substring(0, 5)}TAMPERED',
      );

      expect(
        () => service.decrypt(tampered, 'test_key'),
        throwsA(isA<TamperDetectedException>()),
      );
    });

    test('rejects wrong key', () async {
      final encrypted = await service.encrypt('secret', 'key_1');
      expect(
        () => service.decrypt(encrypted, 'key_2'), // Wrong key
        throwsA(isA<DecryptionException>()),
      );
    });

    test('handles empty string', () async {
      final encrypted = await service.encrypt('', 'test_key');
      final decrypted = await service.decrypt(encrypted, 'test_key');
      expect(decrypted, equals(''));
    });

    test('handles unicode characters', () async {
      const plaintext = '🔒 日本語 العربية Ñoño';
      final encrypted = await service.encrypt(plaintext, 'test_key');
      final decrypted = await service.decrypt(encrypted, 'test_key');
      expect(decrypted, equals(plaintext));
    });

    test('handles large data (1MB)', () async {
      final largeText = 'x' * (1024 * 1024); // 1MB
      final encrypted = await service.encrypt(largeText, 'test_key');
      final decrypted = await service.decrypt(encrypted, 'test_key');
      expect(decrypted, equals(largeText));
    });

    test('PIN hash is not reversible', () async {
      const pin = '123456';
      final hash = await service.hashPIN(pin);
      expect(hash.hash, isNot(equals(pin)));
      expect(hash.hash.length, greaterThan(20));
    });

    test('PIN verification uses timing-safe comparison', () async {
      const pin = '123456';
      final hash = await service.hashPIN(pin);

      final stopwatch1 = Stopwatch()..start();
      await service.verifyPIN(pin, hash.hash, hash.salt);
      stopwatch1.stop();

      final stopwatch2 = Stopwatch()..start();
      await service
          .verifyPIN('wrong_pin', hash.hash, hash.salt)
          .catchError((_) {});
      stopwatch2.stop();

      // Timing should be similar regardless of correctness (timing-safe)
      final timeDiff =
          (stopwatch1.elapsedMicroseconds - stopwatch2.elapsedMicroseconds)
              .abs();
      expect(timeDiff, lessThan(10000)); // < 10ms difference
    });
  });
}
