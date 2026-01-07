import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nav_care_offers_app/core/config/app_config.dart';
import 'package:nav_care_offers_app/core/di/di.dart';
import 'package:nav_care_offers_app/data/chat/models/chat_message_model.dart';
import 'package:nav_care_offers_app/data/chat/models/conversation_model.dart';
import 'package:nav_care_offers_app/presentation/features/authentication/auth_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/messages/viewmodel/chat_messages_cubit.dart';
import 'package:nav_care_offers_app/presentation/features/messages/viewmodel/chat_messages_state.dart';
import 'package:nav_care_offers_app/presentation/features/messages/viewmodel/conversations_cubit.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends StatelessWidget {
  final String? conversationId;
  final String? counterpartUserId;
  final String? doctorName;
  final String? doctorImageUrl;

  const ChatPage({
    super.key,
    this.conversationId,
    this.counterpartUserId,
    this.doctorName,
    this.doctorImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedConversationId = conversationId?.trim();
    final trimmedCounterpartId = counterpartUserId?.trim();
    final initialCounterpart =
        doctorName != null || doctorImageUrl != null
            ? _initialParticipant(doctorName, doctorImageUrl)
            : null;

    if ((trimmedConversationId == null || trimmedConversationId.isEmpty) &&
        (trimmedCounterpartId == null || trimmedCounterpartId.isEmpty)) {
      return const _ChatEmptyPage();
    }

    return BlocProvider(
      create: (_) {
        final cubit = sl<ChatMessagesCubit>();
        if (trimmedConversationId != null &&
            trimmedConversationId.isNotEmpty) {
          cubit.load(
            conversationId: trimmedConversationId,
            currentUserId: context.read<AuthCubit>().state.user?.id,
            initialCounterpart: initialCounterpart,
            counterpartUserId: trimmedCounterpartId,
          );
        } else if (trimmedCounterpartId != null &&
            trimmedCounterpartId.isNotEmpty) {
          cubit.loadEmpty(
            counterpartUserId: trimmedCounterpartId,
            initialCounterpart: initialCounterpart,
          );
        }
        return cubit;
      },
      child: _ChatView(
        doctorName: doctorName,
        doctorImageUrl: doctorImageUrl,
      ),
    );
  }

  ChatParticipant? _initialParticipant(String? name, String? imageUrl) {
    if ((name == null || name.trim().isEmpty) &&
        (imageUrl == null || imageUrl.trim().isEmpty)) {
      return null;
    }
    return ChatParticipant(
      id: '',
      name: name?.trim() ?? '',
      profilePicture: imageUrl?.trim(),
    );
  }
}

class _ChatView extends StatefulWidget {
  final String? doctorName;
  final String? doctorImageUrl;
  static const double _loadMoreTrigger = 140;

  const _ChatView({
    super.key,
    required this.doctorName,
    required this.doctorImageUrl,
  });

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _messageController = TextEditingController();
  static const double _loadMoreTrigger = _ChatView._loadMoreTrigger;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseUrl = sl<AppConfig>().api.baseUrl;
    final userId = context.read<AuthCubit>().state.user?.id ?? '';

    return BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
      builder: (context, state) {
        final title = _resolveTitle(context, state.counterpart?.name);
        final imageUrl = _resolveImage(
          state.counterpart?.profilePicture ?? widget.doctorImageUrl,
          baseUrl,
        );

        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          appBar: AppBar(
            titleSpacing: 0,
            title: InkWell(
              onTap: () => _openDoctorDetails(
                context,
                state.counterpart?.entityId ?? state.counterpart?.id,
              ),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    backgroundImage:
                        imageUrl != null ? NetworkImage(imageUrl) : null,
                    onBackgroundImageError: (_, __) {},
                    child: imageUrl == null
                        ? const Icon(Icons.person_rounded, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'messages.chat_subtitle'.tr(),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.hintColor),
                  ),
                ),
                Expanded(
                  child: _buildBody(context, state, userId),
                ),
                _ChatComposer(
                  controller: _messageController,
                  isSending: state.isSending,
                  onSend: () => _handleSend(context),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ChatMessagesState state,
    String userId,
  ) {
    if (state.status == ChatMessagesStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ChatMessagesStatus.failure) {
      return _ChatError(
        message: state.errorMessage,
        onRetry: () => context.read<ChatMessagesCubit>().refresh(),
      );
    }

    if (state.messages.isEmpty) {
      return _ChatEmpty();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - _loadMoreTrigger) {
          context.read<ChatMessagesCubit>().loadMore();
        }
        return false;
      },
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: state.messages.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.messages.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final message = state.messages[state.messages.length - 1 - index];
          final isMine = message.senderId == userId;
          return _ChatBubble(
            message: message,
            isMine: isMine,
          );
        },
      ),
    );
  }

  String _resolveTitle(BuildContext context, String? counterpartName) {
    final name = counterpartName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final fallback = widget.doctorName?.trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return 'messages.chat_title'.tr();
  }

  String? _resolveImage(String? value, String baseUrl) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (trimmed.startsWith('http')) return trimmed;
    return Uri.parse(baseUrl).resolve(trimmed).toString();
  }

  void _openDoctorDetails(BuildContext context, String? doctorId) {
    final id = doctorId?.trim() ?? '';
    if (id.isEmpty) return;
    context.push('/doctors/$id/detail');
  }

  Future<void> _handleSend(BuildContext context) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final cubit = context.read<ChatMessagesCubit>();
    final success = await cubit.sendMessage(message: text);
    if (!context.mounted) return;
    if (success) {
      _messageController.clear();
      sl<ConversationsCubit>().load();
      setState(() {});
    } else {
      final error = cubit.state.errorMessage ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('messages.chat_send_error'.tr(namedArgs: {'message': error})),
        ),
      );
    }
  }
}

class _ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;
  final ValueChanged<String> onChanged;

  const _ChatComposer({
    required this.controller,
    required this.onSend,
    required this.isSending,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSend = controller.text.trim().isNotEmpty && !isSending;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'messages.chat_input_placeholder'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: canSend ? onSend : null,
            icon: isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMine;

  const _ChatBubble({
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        isMine ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant;
    final textColor =
        isMine ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final timeLabel = _formatTime(context, message.createdAt);
    final bodyText = _resolveBody(context, message);

    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              bodyText,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
            if (timeLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                timeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _resolveBody(BuildContext context, ChatMessageModel message) {
    if (message.type == 'media') {
      return (message.message != null && message.message!.isNotEmpty)
          ? message.message!
          : 'messages.last_message_media'.tr();
    }
    return message.message?.trim().isNotEmpty == true
        ? message.message!.trim()
        : 'messages.last_message_none'.tr();
  }

  String _formatTime(BuildContext context, DateTime? value) {
    if (value == null) return '';
    return DateFormat.Hm(context.locale.toLanguageTag()).format(value);
  }
}

class _ChatEmptyPage extends StatelessWidget {
  const _ChatEmptyPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text('messages.chat_title'.tr()),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chat_bubble_outline_rounded,
                  size: 46, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'messages.chat_empty_title'.tr(),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'messages.chat_empty_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded,
              size: 40, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'messages.chat_empty_title'.tr(),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'messages.chat_empty_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

class _ChatError extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _ChatError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 42, color: Colors.red),
          const SizedBox(height: 10),
          Text(
            'messages.chat_error'.tr(namedArgs: {'message': message ?? ''}),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('messages.search_retry'.tr()),
          ),
        ],
      ),
    );
  }
}
