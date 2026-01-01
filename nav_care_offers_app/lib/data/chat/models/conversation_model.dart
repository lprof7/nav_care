import 'chat_message_model.dart';

class ConversationModel {
  final String id;
  final ConversationCounterpart counterpart;
  final ConversationLastMessage? lastMessage;

  const ConversationModel({
    required this.id,
    required this.counterpart,
    this.lastMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final counterpartRaw = json['counterpart'] as Map<String, dynamic>? ?? {};
    final lastMessageRaw = json['lastMessage'] as Map<String, dynamic>?;
    return ConversationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      counterpart: ConversationCounterpart.fromJson(counterpartRaw),
      lastMessage: lastMessageRaw != null
          ? ConversationLastMessage.fromJson(lastMessageRaw)
          : null,
    );
  }
}

class ChatParticipant {
  final String id;
  final String? entityId;
  final String name;
  final String? profilePicture;

  const ChatParticipant({
    required this.id,
    this.entityId,
    required this.name,
    this.profilePicture,
  });
}

class ChatThread {
  final List<ChatMessageModel> messages;
  final ChatParticipant? counterpart;
  final bool hasMore;
  final String? conversationId;

  const ChatThread({
    required this.messages,
    required this.counterpart,
    required this.hasMore,
    this.conversationId,
  });
}

class ConversationCounterpart {
  final String id;
  final String name;
  final String? email;
  final String? profilePicture;
  final String? phone;

  const ConversationCounterpart({
    required this.id,
    required this.name,
    this.email,
    this.profilePicture,
    this.phone,
  });

  factory ConversationCounterpart.fromJson(Map<String, dynamic> json) {
    return ConversationCounterpart(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

class ConversationLastMessage {
  final String id;
  final String type;
  final String? message;
  final String? mediaUrl;
  final DateTime? createdAt;

  const ConversationLastMessage({
    required this.id,
    required this.type,
    this.message,
    this.mediaUrl,
    this.createdAt,
  });

  factory ConversationLastMessage.fromJson(Map<String, dynamic> json) {
    return ConversationLastMessage(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      message: json['message']?.toString(),
      mediaUrl: json['media_url']?.toString() ?? json['mediaUrl']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
