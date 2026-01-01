import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_care_user_app/core/config/app_config.dart';
import 'package:nav_care_user_app/core/di/di.dart';
import 'package:nav_care_user_app/data/chat/models/conversation_model.dart';
import 'package:nav_care_user_app/presentation/features/authentication/session/auth_session_cubit.dart';
import 'package:nav_care_user_app/presentation/features/messages/viewmodel/conversations_cubit.dart';
import 'package:nav_care_user_app/presentation/features/messages/viewmodel/conversations_state.dart';
import 'package:nav_care_user_app/presentation/shared/ui/molecules/sign_in_required_card.dart';
import 'package:intl/intl.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    final isAuthenticated =
        context.watch<AuthSessionCubit>().state.isAuthenticated;
    if (!isAuthenticated) {
      return _MessagesAuthPrompt(
        onSignIn: () => context.go('/signin'),
        onSignUp: () => context.go('/signup'),
      );
    }

    final cubit = sl<ConversationsCubit>();
    if (cubit.state.status == ConversationsStatus.idle) {
      cubit.load();
    }

    return BlocProvider.value(
      value: cubit,
      child: const _MessagesView(),
    );
  }
}

class _MessagesAuthPrompt extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  const _MessagesAuthPrompt({
    required this.onSignIn,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SignInRequiredCard(
          onSignIn: onSignIn,
          onCreateAccount: onSignUp,
          onGoogleSignIn: null,
        ),
      ),
    );
  }
}

class _MessagesView extends StatelessWidget {
  const _MessagesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseUrl = sl<AppConfig>().api.baseUrl;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'messages.title'.tr(),
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              onTap: () => context.push('/messages/search'),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'messages.search_placeholder'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ConversationsCubit, ConversationsState>(
                builder: (context, state) {
                  if (state.status == ConversationsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == ConversationsStatus.failure) {
                    return _ConversationsError(
                      message: state.errorMessage,
                      onRetry: () =>
                          context.read<ConversationsCubit>().load(),
                    );
                  }

                  if (state.conversations.isEmpty) {
                    return _ConversationsEmpty();
                  }

                  final conversations =
                      _sortConversations(state.conversations);
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<ConversationsCubit>().load(),
                    child: ListView.separated(
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final convo = conversations[index];
                        final counterpart = convo.counterpart;
                        final last = convo.lastMessage;
                        final imageUrl = _resolveImage(
                          counterpart.profilePicture,
                          baseUrl,
                        );
                        final lastText = _buildLastMessagePreview(context, last);
                        final timeLabel = _formatTime(context, last?.createdAt);

                        return _ConversationCard(
                          name: counterpart.name,
                          imageUrl: imageUrl,
                          lastMessage: lastText,
                          timeLabel: timeLabel,
                          onTap: () => context.push(
                            '/messages/chat',
                            extra: {
                              'conversationId': convo.id,
                              'name': counterpart.name,
                              'imageUrl': counterpart.profilePicture,
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _resolveImage(String? value, String baseUrl) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (trimmed.startsWith('http')) return trimmed;
    return Uri.parse(baseUrl).resolve(trimmed).toString();
  }

  String _buildLastMessagePreview(
    BuildContext context,
    ConversationLastMessage? lastMessage,
  ) {
    if (lastMessage == null) {
      return 'messages.last_message_none'.tr();
    }
    final type = lastMessage.type.toString();
    final text = (lastMessage.message ?? '').toString();
    if (type == 'media') {
      return text.isNotEmpty ? text : 'messages.last_message_media'.tr();
    }
    return text.isNotEmpty ? text : 'messages.last_message_none'.tr();
  }

  String _formatTime(BuildContext context, DateTime? value) {
    if (value == null) return '';
    return DateFormat.MMMd(context.locale.toLanguageTag()).format(value);
  }

  List<ConversationModel> _sortConversations(
    List<ConversationModel> conversations,
  ) {
    final sorted = [...conversations];
    sorted.sort((a, b) {
      final aTime = a.lastMessage?.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastMessage?.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return sorted;
  }
}

class _ConversationCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String lastMessage;
  final String timeLabel;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.name,
    required this.imageUrl,
    required this.lastMessage,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: theme.colorScheme.surfaceVariant,
              backgroundImage:
                  imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage(imageUrl!) : null,
              onBackgroundImageError: (_, __) {},
              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? const Icon(Icons.person_rounded)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            ),
            if (timeLabel.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                timeLabel,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.hintColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConversationsEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded,
              size: 46, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'messages.empty_title'.tr(),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'messages.empty_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

class _ConversationsError extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _ConversationsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 42, color: Colors.red),
          const SizedBox(height: 10),
          Text(
            'messages.conversations_error'
                .tr(namedArgs: {'message': message ?? ''}),
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
