import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/models/chat_session.dart';
import '../providers/chat_providers.dart';

// Primary colors for chat UI
const Color kChatPrimaryGreen = Color(0xFF10B981);
const Color kChatBubbleGray = Color(0xFFF3F4F6);
const Color kDarkGray = Color(0xFF1F2937);
const Color kGrayText = Color(0xFF6B7280);

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendMessage(ChatSession session) async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _chatController.clear();
    await ref
        .read(chatMessagesNotifierProvider(session.id).notifier)
        .send(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(activeChatSessionProvider);

    return sessionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorView(
        message: '채팅 세션을 불러오지 못했어요: $error',
        onRetry: () => ref.refresh(activeChatSessionProvider),
      ),
      data: (session) {
        final messagesState = ref.watch(chatMessagesNotifierProvider(session.id));

        return Column(
          children: [
            _ChatHeader(session: session),
            Expanded(
              child: messagesState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: kChatPrimaryGreen),
                ),
                error: (error, _) => _ErrorView(
                  message: '메시지를 불러오지 못했어요: $error',
                  onRetry: () => ref
                      .read(chatMessagesNotifierProvider(session.id).notifier)
                      .load(),
                ),
                data: (messages) {
                  _scrollToBottom();
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _MessageBubble(message: messages[index]);
                    },
                  );
                },
              ),
            ),
            _ChatInputBar(
              controller: _chatController,
              onSend: () => _sendMessage(session),
            ),
          ],
        );
      },
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.session});

  final ChatSession session;

  @override
  Widget build(BuildContext context) {
    final doctor = session.doctor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kChatPrimaryGreen.withValues(alpha: 0.12),
            child: const Icon(Icons.health_and_safety, color: kChatPrimaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.subject ?? '방문 진료 상담',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kDarkGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  doctor != null
                      ? '${doctor.name} · ${doctor.specialty}'
                      : '의료진이 배정되었습니다',
                  style: const TextStyle(
                    color: kGrayText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // Placeholder for future call/voice
            },
            icon: const Icon(Icons.refresh, size: 16, color: kGrayText),
            label: const Text(
              '새로고침',
              style: TextStyle(color: kGrayText, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.sender == 'user';
    final alignment =
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final bubbleColor = isUser ? kChatPrimaryGreen : kChatBubbleGray;
    final textColor = isUser ? Colors.white : kDarkGray;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: kChatBubbleGray,
              child: Icon(Icons.person, color: kDarkGray, size: 18),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            const CircleAvatar(
              radius: 16,
              backgroundColor: kChatPrimaryGreen,
              child: Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF4B5563),
              ),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "메시지를 입력하세요",
                  filled: true,
                  fillColor: kChatBubbleGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: kChatPrimaryGreen,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
              ),
              child: const Icon(Icons.send, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: kDarkGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
