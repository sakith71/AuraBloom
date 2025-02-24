enum MessageType { text, symptom, advice, warning }

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
  });
}
