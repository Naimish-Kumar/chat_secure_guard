import 'dart:io';
import 'dart:typed_data';
import 'package:sodium_libs/sodium_libs.dart';

class FileCrypto {
  /// Encrypts a file using libsodium secretbox (symmetric encryption).
  /// Appends '.enc' to the filename.
  /// Note: This loads the entire file into memory. For very large files (GBs), streaming is recommended.
  Future<File> encryptFile(
    File file,
    Uint8List key, {
    required Sodium sodium,
  }) async {
    final bytes = await file.readAsBytes();
    final nonce = sodium.randombytes.buf(sodium.crypto.secretBox.nonceBytes);

    final secureKey = sodium.secureCopy(key);

    try {
      final encrypted = sodium.crypto.secretBox.easy(
        message: bytes,
        nonce: nonce,
        key: secureKey,
      );

      // Write nonce + encrypted data
      final builder = BytesBuilder(copy: false);
      builder.add(nonce);
      builder.add(encrypted);

      final newFile = File("${file.path}.enc");
      return newFile.writeAsBytes(builder.toBytes());
    } finally {
      secureKey.dispose();
    }
  }

  /// Decrypts a file.
  /// Attempts to remove '.enc' from the filename for the output.
  Future<File> decryptFile(
    File file,
    Uint8List key, {
    required Sodium sodium,
  }) async {
    final bytes = await file.readAsBytes();
    final nonceLength = sodium.crypto.secretBox.nonceBytes;

    if (bytes.length < nonceLength) {
      throw Exception('Invalid encrypted file format');
    }

    final nonce = bytes.sublist(0, nonceLength);
    final cipher = bytes.sublist(nonceLength);

    final secureKey = sodium.secureCopy(key);

    try {
      final decrypted = sodium.crypto.secretBox.openEasy(
        cipherText: cipher,
        nonce: nonce,
        key: secureKey,
      );

      String newPath = file.path;
      if (newPath.endsWith('.enc')) {
        newPath = newPath.substring(0, newPath.length - 4);
      } else {
        newPath = "$newPath.decrypted";
      }

      final newFile = File(newPath);
      return newFile.writeAsBytes(decrypted);
    } finally {
      secureKey.dispose();
    }
  }
}
