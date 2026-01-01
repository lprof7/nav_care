class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String type;
  final String? message;
  final String? mediaUrl;
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    this.message,
    this.mediaUrl,
    this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      conversationId:
          json['conversation_id']?.toString() ?? json['conversationId']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? json['senderId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString(),
      mediaUrl: json['media_url']?.toString() ?? json['mediaUrl']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
