import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/data/chat/models/chat_message_model.dart';
import 'package:nav_care_offers_app/data/chat/models/conversation_model.dart';

enum ChatMessagesStatus { idle, loading, success, failure }

class ChatMessagesState extends Equatable {
  final ChatMessagesStatus status;
  final String? conversationId;
  final String? counterpartUserId;
  final List<ChatMessageModel> messages;
  final ChatParticipant? counterpart;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final bool isSending;

  const ChatMessagesState({
    this.status = ChatMessagesStatus.idle,
    this.conversationId,
    this.counterpartUserId,
    this.messages = const [],
    this.counterpart,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.errorMessage,
    this.isSending = false,
  });

  ChatMessagesState copyWith({
    ChatMessagesStatus? status,
    String? conversationId,
    String? counterpartUserId,
    List<ChatMessageModel>? messages,
    ChatParticipant? counterpart,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    bool? isSending,
  }) {
    return ChatMessagesState(
      status: status ?? this.status,
      conversationId: conversationId ?? this.conversationId,
      counterpartUserId: counterpartUserId ?? this.counterpartUserId,
      messages: messages ?? this.messages,
      counterpart: counterpart ?? this.counterpart,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [
        status,
        conversationId,
        counterpartUserId,
        messages,
        counterpart,
        isLoadingMore,
        hasMore,
        errorMessage,
        isSending,
      ];
}
