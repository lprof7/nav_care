import 'package:nav_care_offers_app/data/chat/chat_remote_service.dart';
import 'package:nav_care_offers_app/data/chat/models/chat_message_model.dart';
import 'package:nav_care_offers_app/data/chat/models/conversation_model.dart';

class ChatRepository {
  ChatRepository({required ChatRemoteService remoteService})
      : _remoteService = remoteService;

  final ChatRemoteService _remoteService;

  Future<List<ConversationModel>> listConversations() async {
    final result = await _remoteService.listConversations();
    if (!result.isSuccess || result.data == null) {
      final message =
          result.error?.message ?? 'Failed to load conversations.';
      throw Exception(message);
    }

    final payload = result.data!;
    final data = payload['data'];
    final items = _extractList(data);
    return items.map(ConversationModel.fromJson).toList(growable: false);
  }

  Future<ChatThread> listMessages({
    required String conversationId,
    required String? currentUserId,
    int page = 1,
    int limit = 50,
  }) async {
    final result = await _remoteService.listMessages(
      conversationId: conversationId,
      page: page,
      limit: limit,
    );
    if (!result.isSuccess || result.data == null) {
      final message =
          result.error?.message ?? 'Failed to load conversation messages.';
      throw Exception(message);
    }

    final payload = result.data!;
    final data = _asMap(payload['data']) ?? payload;
    final messagesRaw = _extractList(data['messages']);
    final messages = messagesRaw
        .map(ChatMessageModel.fromJson)
        .toList(growable: false);
    final hasMore = messages.length >= limit;

    final entityA = _asMap(data['entityA']);
    final entityB = _asMap(data['entityB']);
    final counterpart =
        _resolveCounterpart(entityA, entityB, currentUserId);

    return ChatThread(
      messages: messages,
      counterpart: counterpart,
      hasMore: hasMore,
      conversationId: conversationId,
    );
  }

  Future<String> createConversation({required String userId}) async {
    final result = await _remoteService.createConversation(userId: userId);
    if (!result.isSuccess || result.data == null) {
      final message =
          result.error?.message ?? 'Failed to create conversation.';
      throw Exception(message);
    }
    final data = result.data!;
    final payload = _asMap(data['data']) ?? data;
    final id = payload['conversationId']?.toString();
    if (id == null || id.isEmpty) {
      throw Exception('Failed to create conversation.');
    }
    return id;
  }

  Future<ChatMessageModel> sendMessage({
    required String conversationId,
    required String message,
    String type = 'text',
    String? imagePath,
  }) async {
    final result = await _remoteService.sendMessage(
      conversationId: conversationId,
      type: type,
      message: message,
      imagePath: imagePath,
    );
    if (!result.isSuccess || result.data == null) {
      final msg = result.error?.message ?? 'Failed to send message.';
      throw Exception(msg);
    }
    final payload = result.data!;
    final data = _asMap(payload['data']) ?? payload;
    return ChatMessageModel.fromJson(data);
  }

  List<Map<String, dynamic>> _extractList(dynamic value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    if (value is Map<String, dynamic>) {
      for (final entry in value.values) {
        final list = _extractList(entry);
        if (list.isNotEmpty) return list;
      }
    }
    return <Map<String, dynamic>>[];
  }

  ChatParticipant? _resolveCounterpart(
    Map<String, dynamic>? entityA,
    Map<String, dynamic>? entityB,
    String? currentUserId,
  ) {
    final a = _participantFromEntity(entityA);
    final b = _participantFromEntity(entityB);
    if (a == null && b == null) return null;
    if (currentUserId == null || currentUserId.isEmpty) {
      return a ?? b;
    }
    if (a != null && a.id == currentUserId) return b ?? a;
    if (b != null && b.id == currentUserId) return a ?? b;
    return a ?? b;
  }

  ChatParticipant? _participantFromEntity(Map<String, dynamic>? entity) {
    if (entity == null || entity.isEmpty) return null;
    final data = _asMap(entity['data']) ?? entity;
    final user = _asMap(data['user']) ?? data;
    final id = user['_id']?.toString() ?? data['_id']?.toString() ?? '';
    final entityId = data['_id']?.toString();
    final name = user['name']?.toString() ?? data['name']?.toString() ?? '';
    if (id.isEmpty && name.isEmpty) return null;
    final profilePicture = user['profilePicture']?.toString() ??
        user['avatar']?.toString() ??
        data['profilePicture']?.toString();
    return ChatParticipant(
      id: id,
      entityId: entityId,
      name: name,
      profilePicture: profilePicture,
    );
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic val) => MapEntry(key.toString(), val));
    }
    return null;
  }
}
