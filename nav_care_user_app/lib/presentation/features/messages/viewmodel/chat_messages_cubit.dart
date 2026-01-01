import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_care_user_app/data/chat/chat_repository.dart';
import 'package:nav_care_user_app/data/chat/models/chat_message_model.dart';
import 'package:nav_care_user_app/data/chat/models/conversation_model.dart';

import 'chat_messages_state.dart';

class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  ChatMessagesCubit({required ChatRepository repository})
      : _repository = repository,
        super(const ChatMessagesState());

  final ChatRepository _repository;
  static const int _pageSize = 50;
  int _page = 1;
  String? _currentUserId;

  Future<void> load({
    required String conversationId,
    String? currentUserId,
    ChatParticipant? initialCounterpart,
    String? counterpartUserId,
  }) async {
    _page = 1;
    _currentUserId = currentUserId;
    emit(state.copyWith(
      status: ChatMessagesStatus.loading,
      conversationId: conversationId,
      counterpartUserId: counterpartUserId,
      messages: const [],
      counterpart: initialCounterpart,
      isLoadingMore: false,
      hasMore: false,
      errorMessage: null,
    ));
    await _fetchPage();
  }

  Future<void> loadEmpty({
    required String counterpartUserId,
    ChatParticipant? initialCounterpart,
  }) async {
    _page = 1;
    emit(state.copyWith(
      status: ChatMessagesStatus.success,
      conversationId: null,
      counterpartUserId: counterpartUserId,
      messages: const [],
      counterpart: initialCounterpart,
      isLoadingMore: false,
      hasMore: false,
      errorMessage: null,
    ));
  }

  Future<void> refresh() async {
    final conversationId = state.conversationId;
    if (conversationId == null || conversationId.isEmpty) return;
    _page = 1;
    emit(state.copyWith(
      status: ChatMessagesStatus.loading,
      messages: const [],
      isLoadingMore: false,
      hasMore: false,
      errorMessage: null,
    ));
    await _fetchPage();
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    final conversationId = state.conversationId;
    if (conversationId == null || conversationId.isEmpty) return;
    emit(state.copyWith(isLoadingMore: true));
    _page += 1;
    await _fetchPage(isLoadMore: true);
  }

  Future<bool> sendMessage({
    required String message,
    String type = 'text',
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return false;
    emit(state.copyWith(isSending: true, errorMessage: null));
    try {
      var conversationId = state.conversationId;
      if (conversationId == null || conversationId.isEmpty) {
        final counterpartUserId = state.counterpartUserId;
        if (counterpartUserId == null || counterpartUserId.isEmpty) {
          throw Exception('Missing conversation recipient.');
        }
        conversationId =
            await _repository.createConversation(userId: counterpartUserId);
        emit(state.copyWith(conversationId: conversationId));
      }

      final sent = await _repository.sendMessage(
        conversationId: conversationId!,
        message: trimmed,
        type: type,
      );

      final merged = _mergeMessages(state.messages, [sent]);
      emit(state.copyWith(
        status: ChatMessagesStatus.success,
        messages: merged,
        isSending: false,
        errorMessage: null,
      ));
      return true;
    } catch (error) {
      emit(state.copyWith(
        isSending: false,
        errorMessage: _normalizeError(error),
      ));
      return false;
    }
  }

  Future<void> _fetchPage({bool isLoadMore = false}) async {
    final conversationId = state.conversationId;
    if (conversationId == null || conversationId.isEmpty) return;
    try {
      final result = await _repository.listMessages(
        conversationId: conversationId,
        currentUserId: _currentUserId,
        page: _page,
        limit: _pageSize,
      );
      final previousCount = state.messages.length;
      final merged = _mergeMessages(state.messages, result.messages);
      final hasNewItems = merged.length > previousCount;
      emit(state.copyWith(
        status: ChatMessagesStatus.success,
        messages: merged,
        counterpart: result.counterpart ?? state.counterpart,
        isLoadingMore: false,
        hasMore: result.hasMore && (!isLoadMore || hasNewItems),
        errorMessage: null,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ChatMessagesStatus.failure,
        isLoadingMore: false,
        errorMessage: _normalizeError(error),
      ));
    }
  }

  List<ChatMessageModel> _mergeMessages(
    List<ChatMessageModel> current,
    List<ChatMessageModel> incoming,
  ) {
    if (current.isEmpty) return _sortMessages(incoming);
    final map = {for (final msg in current) msg.id: msg};
    for (final msg in incoming) {
      map[msg.id] = msg;
    }
    return _sortMessages(map.values.toList());
  }

  List<ChatMessageModel> _sortMessages(List<ChatMessageModel> messages) {
    final sorted = [...messages];
    sorted.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.compareTo(bTime);
    });
    return sorted;
  }

  String _normalizeError(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '').trim();
  }
}
