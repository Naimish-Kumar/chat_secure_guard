import 'dart:convert';
import 'dart:typed_data';
import 'package:sodium_libs/sodium_libs.dart';

class EncryptionService {
  /// Encrypts a message using libsodium.
  /// Requires an initialized [Sodium] instance.
  String encryptMessage({
    required Sodium sodium,
    required String message,
    required Uint8List receiverPublicKey,
    required Uint8List senderPrivateKey,
  }) {
    final nonce = sodium.randombytes.buf(sodium.crypto.box.nonceBytes);
    final messageBytes = utf8.encode(message);

    final secureKey = sodium.secureCopy(senderPrivateKey);

    try {
      final encrypted = sodium.crypto.box.easy(
        message: Uint8List.fromList(messageBytes),
        nonce: nonce,
        publicKey: receiverPublicKey,
        secretKey: secureKey,
      );

      // Combine nonce + encrypted data for transmission
      final builder = BytesBuilder();
      builder.add(nonce);
      builder.add(encrypted);

      return base64Encode(builder.toBytes());
    } finally {
      secureKey.dispose();
    }
  }

  /// Decrypts a message using libsodium.
  /// Requires an initialized [Sodium] instance.
  String decryptMessage({
    required Sodium sodium,
    required String encryptedMessage,
    required Uint8List senderPublicKey,
    required Uint8List receiverPrivateKey,
  }) {
    final decodedBytes = base64Decode(encryptedMessage);
    final nonceBytes = sodium.crypto.box.nonceBytes;

    if (decodedBytes.length < nonceBytes) {
      throw Exception('Invalid encrypted message format: too short');
    }

    final nonce = decodedBytes.sublist(0, nonceBytes);
    final cipher = decodedBytes.sublist(nonceBytes);

    final secureKey = sodium.secureCopy(receiverPrivateKey);

    try {
      final decrypted = sodium.crypto.box.openEasy(
        cipherText: cipher,
        nonce: nonce,
        publicKey: senderPublicKey,
        secretKey: secureKey,
      );

      return utf8.decode(decrypted);
    } finally {
      secureKey.dispose();
    }
  }
}
