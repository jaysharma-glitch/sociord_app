class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;
  final bool isRead;
  final ChatMessage? replyToMessage;
  final List<String> reactions; // emoji reactions

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
    this.isRead = false,
    this.replyToMessage,
    this.reactions = const [],
  });
}
