class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.sender,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String sender;
  final String content;
  final DateTime createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
      sender: json['sender']?.toString() ?? 'user',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
