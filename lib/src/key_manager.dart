import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sodium_libs/sodium_libs.dart';

class KeyManager {
  final storage = const FlutterSecureStorage();

  // Cache keys in memory for performance
  Uint8List? _cachedPrivateKey;
  Uint8List? _cachedPublicKey;

  /// loads keys from secure storage into memory.
  Future<void> loadKeys() async {
    final results = await Future.wait([
      storage.read(key: 'private_key'),
      storage.read(key: 'public_key'),
    ]);

    final privateKeyStr = results[0];
    final publicKeyStr = results[1];

    if (privateKeyStr != null) {
      _cachedPrivateKey = base64Decode(privateKeyStr);
    }
    if (publicKeyStr != null) {
      _cachedPublicKey = base64Decode(publicKeyStr);
    }
  }

  Future<void> generateKeyPair(Sodium sodium) async {
    final keyPair = sodium.crypto.box.keyPair();

    try {
      // SecureKey is unsafe to store directly in standard variables/storage
      // without extraction. We extract it here to Uint8List for storage/caching.
      // Use .extractBytes() to safely access the raw bytes and copy them.
      _cachedPrivateKey = keyPair.secretKey.extractBytes();
      _cachedPublicKey = keyPair.publicKey;

      await storage.write(
        key: 'public_key',
        value: base64Encode(_cachedPublicKey!),
      );

      await storage.write(
        key: 'private_key',
        value: base64Encode(_cachedPrivateKey!),
      );
    } finally {
      // Always dispose the KeyPair to clear the SecureKey from sodium memory
      keyPair.dispose();
    }
  }

  Future<Uint8List> getPrivateKey() async {
    if (_cachedPrivateKey != null) return _cachedPrivateKey!;

    // Fallback if not loaded
    await loadKeys();
    if (_cachedPrivateKey == null) {
      throw Exception('Private key not found. Call init() first.');
    }
    return _cachedPrivateKey!;
  }

  Future<Uint8List> getPublicKey() async {
    if (_cachedPublicKey != null) return _cachedPublicKey!;

    // Fallback if not loaded
    await loadKeys();
    if (_cachedPublicKey == null) {
      throw Exception('Public key not found. Call init() first.');
    }
    return _cachedPublicKey!;
  }

  bool get hasKeys => _cachedPrivateKey != null && _cachedPublicKey != null;
}
