
## Overview
`chat_secure_guard` is a production-grade Flutter package for **End-to-End Encryption (E2EE)**. It provides military-grade security using **libsodium** and now supports the **Double Ratchet Algorithm** (used by Signal & WhatsApp) for Perfect Forward Secrecy.

It is designed to work seamlessly with its counterpart: `chat-secure-guard-js` (for Web/Node/React Native).

## Features
- 🔐 **End-to-End Encryption**: Messages are encrypted on the device and can only be read by the intended recipient.
- 🔄 **Double Ratchet Algorithm**: Rotates keys for every message. If a key is compromised, past and future messages remain secure.
- 🔑 **Secure Key Management**: Automated generation and storage of ED25519 keys.
- 📁 **File Encryption**: Securely encrypt and decrypt files (images, videos, docs).
- ⚡ **Cross-Platform**: Fully compatible with Android, iOS, Web, Windows, macOS, and Linux.

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  chat_secure_guard: ^0.0.2
```

> **Note:** This package automatically includes `flutter_secure_storage` and `sodium_libs`.
> However, for `flutter_secure_storage` on Android, you might need to set `minSdkVersion` to 18 in your `android/app/build.gradle`.

## Usage

### 1. Initialization
Initialize the library at the start of your app. This generates Identity Keys if they don't exist.

```dart
await ChatSecureGuard.init();
```

### 2. Double Ratchet (WhatsApp-style Encryption) 🚀 *Recommended*

This is the most secure way to chat. It handles key rotation automatically.

#### Step A: Setup Sessions
You need a "Shared Secret" to start a session. This is usually derived from an initial Key Exchange (X3DH) or simply by exchanging public keys via your server.

**Sender (Alice):**
```dart
// 1. Get Sodium Instance
final sodium = ChatSecureGuard.sodium;
final ratchet = DoubleRatchet(sodium);

// 2. Initialize Sender Session
// 'sharedSecret': A 32-byte key you agreed upon (via server/QR code)
// 'bobPublicKey': Bob's Identity Public Key
final aliceSession = ratchet.initSenderSession(sharedSecret, bobPublicKey);
```

**Receiver (Bob):**
```dart
// 1. Get Sodium Instance
final sodium = ChatSecureGuard.sodium;
final ratchet = DoubleRatchet(sodium);

// 2. Initialize Receiver Session
// 'bobRatchetKeyPair': The key pair Bob published to the server (PreKey)
final bobSession = ratchet.initReceiverSession(sharedSecret, bobRatchetKeyPair);
```

#### Step B: Send Message
```dart
final packet = ratchet.encrypt(aliceSession, "Hello Secure World!");

// 'packet' is a Map containing:
// - header_key: The new ratchet public key
// - nonce: Random nonce
// - ciphertext: The encrypted message
// Send this whole packet to Bob via your server.
```

#### Step C: Receive Message
```dart
// Bob receives 'packet' from server
final message = ratchet.decrypt(bobSession, packet);
print(message); // "Hello Secure World!"
```

### 3. Basic Encryption (Legacy / Stateless)
Simple Public/Private key encryption without session management.

```dart
// Encrypt
final encrypted = await ChatSecureGuard.encrypt(
  message: "Secret!",
  receiverPublicKey: otherUserPublicKey,
);

// Decrypt
final decrypted = await ChatSecureGuard.decrypt(
  encryptedMessage: encrypted,
  senderPublicKey: senderPublicKey,
);
```

### 4. File Encryption
Encrypt unread raw files before uploading them.

```dart
// Encrypt
final encryptedFile = await ChatSecureGuard.encryptFile(
  file: File('image.png'),
  key: symmetricKey,
);

// Decrypt
final originalFile = await ChatSecureGuard.decryptFile(
  file: encryptedFile,
  key: symmetricKey,
);
```

## Security Design
*   **Algorithm**: X25519 for Key Exchange, XSalsa20-Poly1305 for Encryption, BLAKE2b for KDF.
*   **Storage**: Keys are stored in Android Keystore / iOS Keychain via `flutter_secure_storage`.
*   **Safety**: Uses `sodium_libs` FFI bindings for high performance and security.
