# chat_secure_guard — Complete Package Documentation

## 1. Overview
chat_secure_guard is a Flutter package that provides:
- ✅ End-to-End Encryption (E2EE) for messages
- ✅ Secure file encryption & decryption
- ✅ Public/Private key generation
- ✅ Secure local storage support
- ✅ Easy integration API for chat apps

The goal is to allow developers to add WhatsApp-like encryption to their Flutter apps with minimal effort.

## 2. Features
- 🔐 **Asymmetric Encryption (Public/Private Keys)**
- 🔑 **Secure Key Pair Generation**
- 💬 **Message Encryption & Decryption**
- 📁 **File Encryption Support**
- 🗄 **Secure Local Storage**
- ⚡ **Lightweight API**
- 📱 **Android / iOS Support**
- 🔄 **Session Key Support (Optional Advanced)**

## 3. Technology Stack
Recommended libraries:
- **Encryption**: libsodium (via `sodium` package)
- **Secure Storage**: `flutter_secure_storage`
- **Hashing**: `crypto`
- **File Handling**: `dart:io`

## 4. Installation

Add in `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  sodium: ^2.0.0
  flutter_secure_storage: ^9.0.0
  crypto: ^3.0.3
```

## 5. Usage

### Initialization
Initialize the package before use, typically in `main()` or your app startup logic. This generates keys if they don't exist.

```dart
await ChatSecureGuard.init();
```

### Retrieving Public Key
Get the current user's public key to share with others.

```dart
final publicKey = await ChatSecureGuard.getPublicKey();
```

### Message Encryption
Encrypt a message using the recipient's public key.

```dart
final encrypted = await ChatSecureGuard.encrypt(
  message: "Hello Secure World",
  receiverPublicKey: receiverPublicKey, // Uint8List
);
```

### Message Decryption
Decrypt a received message using the sender's public key.

```dart
final decrypted = await ChatSecureGuard.decrypt(
  encryptedMessage: encryptedString,
  senderPublicKey: senderPublicKey, // Uint8List
);
```

### File Encryption
Encrypt a file with a symmetric key.

```dart
final encryptedFile = await ChatSecureGuard.encryptFile(
  file: myFile,
  key: symmetricKey, // Uint8List
);
```

### File Decryption
Decrypt a file using the same symmetric key.

```dart
final decryptedFile = await ChatSecureGuard.decryptFile(
  file: encryptedFile,
  key: symmetricKey, // Uint8List
);
```

## 6. Architecture
**Layer Architecture:**
App Layer → Dart API Layer (chat_secure_guard) → Crypto Engine (libsodium) → Secure Storage

**Modules:**
- **Key Manager**: Handles key generation and secure storage.
- **Encryption Engine**: Handles message crypto.
- **File Encryption**: Handles file crypto.
- **Storage Manager**: Wrapper for secure storage.
- **Public API**: Facade for easy integration.

## 7. Security Best Practices
- ✅ Use nonce for every message (handled automatically).
- ✅ Never reuse keys incorrectly.
- ✅ Store private keys securely (handled via FlutterSecureStorage).
- ✅ Use forward secrecy (advanced feature).
- ✅ Rotate session keys periodically.

## 8. Sending Encrypted Chat Flow
1. **User A**: Encrypt with User B's Public Key → Send to Server.
2. **Server**: Stores encrypted message only (cannot read it).
3. **User B**: Receive → Decrypt with Private Key.

## 9. File Sharing Flow
Select File → Encrypt File → Upload Encrypted File → Receiver Download → Decrypt File.
