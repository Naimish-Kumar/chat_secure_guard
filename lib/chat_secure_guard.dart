import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:sodium_libs/sodium_libs.dart'; // Import sodium types

import 'src/key_manager.dart';
import 'src/encryption_service.dart';
import 'src/file_crypto.dart';

export 'src/models.dart';
export 'src/key_manager.dart';
export 'src/encryption_service.dart';
export 'src/file_crypto.dart';
export 'src/double_ratchet.dart'; // Export new Double Ratchet implementation

class ChatSecureGuard {
  static final KeyManager _keyManager = KeyManager();
  static final EncryptionService _encryptionService = EncryptionService();
  static final FileCrypto _fileCrypto = FileCrypto();

  static Sodium? _sodium;

  /// Initialize the secure guard. Should be called before any other operations.
  /// 1. Initializes libsodium (heavy operation, do once).
  /// 2. Loads keys from secure storage into memory (avoid disk I/O later).
  static Future<void> init() async {
    // 1. Initialize Sodium
    _sodium ??= await SodiumInit.init();

    // 2. Load keys into memory for fast access
    await _keyManager.loadKeys();

    if (!_keyManager.hasKeys) {
      await _keyManager.generateKeyPair(_sodium!);
    }
  }

  static Sodium get _sodiumInstance {
    if (_sodium == null) {
      throw Exception(
        'ChatSecureGuard not initialized. Call ChatSecureGuard.init() first.',
      );
    }
    return _sodium!;
  }

  /// Returns the internal Sodium instance (for advanced usage like DoubleRatchet).
  static Sodium get sodium => _sodiumInstance;

  /// Regenerate keys. This invalidates all previous messages efficiently.
  static Future<void> regenerateKeys() async {
    await _keyManager.generateKeyPair(_sodiumInstance);
  }

  /// Get the current user's public key (fast, from memory).
  static Future<Uint8List> getPublicKey() async {
    return _keyManager.getPublicKey();
  }

  /// Encrypts a text message for a specific receiver.
  /// Uses cached keys and sodium instance for max performance.
  static Future<String> encrypt({
    required String message,
    required Uint8List receiverPublicKey,
  }) async {
    final senderPrivateKey = await _keyManager.getPrivateKey();
    return _encryptionService.encryptMessage(
      sodium: _sodiumInstance,
      message: message,
      receiverPublicKey: receiverPublicKey,
      senderPrivateKey: senderPrivateKey,
    );
  }

  /// Decrypts a text message from a specific sender.
  static Future<String> decrypt({
    required String encryptedMessage,
    required Uint8List senderPublicKey,
  }) async {
    final receiverPrivateKey = await _keyManager.getPrivateKey();
    return _encryptionService.decryptMessage(
      sodium: _sodiumInstance,
      encryptedMessage: encryptedMessage,
      senderPublicKey: senderPublicKey,
      receiverPrivateKey: receiverPrivateKey,
    );
  }

  /// Encrypts a file using a symmetric key.
  static Future<File> encryptFile({
    required File file,
    required Uint8List key,
  }) async {
    return _fileCrypto.encryptFile(file, key, sodium: _sodiumInstance);
  }

  /// Decrypts a file using a symmetric key.
  static Future<File> decryptFile({
    required File file,
    required Uint8List key,
  }) async {
    return _fileCrypto.decryptFile(file, key, sodium: _sodiumInstance);
  }
}
