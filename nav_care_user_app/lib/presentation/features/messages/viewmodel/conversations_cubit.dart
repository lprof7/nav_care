import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/chat/chat_repository.dart';

import 'conversations_state.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  ConversationsCubit({required ChatRepository repository})
      : _repository = repository,
        super(const ConversationsState());

  final ChatRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: ConversationsStatus.loading, errorMessage: null));
    try {
      final conversations = await _repository.listConversations();
      emit(state.copyWith(
        status: ConversationsStatus.success,
        conversations: conversations,
        errorMessage: null,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ConversationsStatus.failure,
        errorMessage: _normalizeError(error),
      ));
    }
  }

  String _normalizeError(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '').trim();
  }
}
