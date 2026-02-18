import 'package:flutter/material.dart';
import 'dart:async';

import 'package:chat_secure_guard/chat_secure_guard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = 'Initializing...';
  String _encryptedMessage = '';
  String _decryptedMessage = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String status;
    try {
      await ChatSecureGuard.init();

      // Simulate a chat flow
      final senderPublicKey = await ChatSecureGuard.getPublicKey();
      // In a real app, receiverPublicKey would be fetched from server.
      // Here we simulate self-sending just to test encryption/decryption flow.
      final receiverPublicKey = senderPublicKey;

      final message = "Hello Secure World!";
      final encrypted = await ChatSecureGuard.encrypt(
        message: message,
        receiverPublicKey: receiverPublicKey,
      );

      _encryptedMessage = encrypted;

      final decrypted = await ChatSecureGuard.decrypt(
        encryptedMessage: encrypted,
        senderPublicKey: senderPublicKey,
      );

      _decryptedMessage = decrypted;
      status = 'Success';
    } catch (e) {
      status = 'Failed: $e';
    }

    if (!mounted) return;

    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ChatSecureGuard Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Status: $_status\n'),
              const Divider(),
              const Text('Encrypted Message (Base64):'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _encryptedMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              const Divider(),
              Text('Decrypted Message: $_decryptedMessage'),
            ],
          ),
        ),
      ),
    );
  }
}
