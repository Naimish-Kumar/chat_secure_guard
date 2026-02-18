/// Library for data models used in the chat_secure_guard package.
/// Currently empty as usage relies on primitive types and standard library classes.
class ChatSecureGuardException implements Exception {
  final String message;
  ChatSecureGuardException(this.message);
  @override
  String toString() => "ChatSecureGuardException: $message";
}
