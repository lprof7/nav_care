import 'package:equatable/equatable.dart';
import 'package:nav_care_offers_app/data/chat/models/conversation_model.dart';

enum ConversationsStatus { idle, loading, success, failure }

class ConversationsState extends Equatable {
  final ConversationsStatus status;
  final List<ConversationModel> conversations;
  final String? errorMessage;

  const ConversationsState({
    this.status = ConversationsStatus.idle,
    this.conversations = const [],
    this.errorMessage,
  });

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<ConversationModel>? conversations,
    String? errorMessage,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, conversations, errorMessage];
}
