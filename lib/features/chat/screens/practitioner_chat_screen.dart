import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/models/chat_session.dart';
import '../../../core/services/auth_session.dart';
import '../../../core/services/chat_realtime_service.dart';
import '../providers/chat_providers.dart';

// Modern color palette for practitioner chat UI
const Color kPractitionerChatPrimaryBlue = Color(0xFF3B82F6);
const Color kPractitionerChatPrimaryBlueLight = Color(0xFFDBEAFE);
const Color kPractitionerChatBubbleGray = Color(0xFFF9FAFB);
const Color kPractitionerChatDarkGray = Color(0xFF111827);
const Color kPractitionerChatMediumGray = Color(0xFF6B7280);
const Color kPractitionerChatLightGray = Color(0xFFE5E7EB);
const Color kPractitionerChatBackground = Color(0xFFF3F4F6);

class PractitionerChatScreen extends ConsumerStatefulWidget {
  const PractitionerChatScreen({super.key, this.sessionId});

  final String? sessionId;

  @override
  ConsumerState<PractitionerChatScreen> createState() => _PractitionerChatScreenState();
}

class _PractitionerChatScreenState extends ConsumerState<PractitionerChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatRealtimeService? _realtime;
  String? _currentRealtimeSessionId;

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    _realtime?.close();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent + 100);
      }
    });
  }

  Future<void> _sendMessage(ChatSession session) async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _chatController.clear();
    await ref
        .read(practitionerChatMessagesNotifierProvider(session.id).notifier)
        .send(text, onSent: () {
      // 메시지 전송 후 채팅 목록 새로고침
      ref.refresh(chatSessionsProvider);
    });
    _scrollToBottom();
  }

  void _ensureRealtime(ChatSession session) {
    final token = AuthSession.instance.token;
    if (token == null || token.isEmpty) {
      return;
    }
    if (_currentRealtimeSessionId == session.id &&
        _realtime?.isConnected == true) {
      return;
    }
    _realtime?.close();
    _currentRealtimeSessionId = session.id;
    _realtime = ChatRealtimeService(
      sessionId: session.id,
      token: token,
      onMessage: (message) {
        if (!mounted) return;
        ref
            .read(practitionerChatMessagesNotifierProvider(session.id).notifier)
            .addRealtimeMessage(message);
        _scrollToBottom();
      },
    )..connect();
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = widget.sessionId != null
        ? ref.watch(chatSessionByIdProvider(widget.sessionId!))
        : ref.watch(activeChatSessionProvider);

    return sessionAsync.when(
      loading: () => Scaffold(
        backgroundColor: kPractitionerChatBackground,
        body: const Center(
          child: CircularProgressIndicator(color: kPractitionerChatPrimaryBlue),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: kPractitionerChatBackground,
        body: _ErrorView(
          message: '채팅 세션을 불러오지 못했어요: $error',
          onRetry: () => ref.refresh(activeChatSessionProvider),
        ),
      ),
      data: (session) {
        _ensureRealtime(session);
        final messagesState = ref.watch(practitionerChatMessagesNotifierProvider(session.id));

        return Scaffold(
          backgroundColor: kPractitionerChatBackground,
          body: SafeArea(
            child: Column(
              children: [
                _ModernPractitionerChatHeader(session: session),
                Expanded(
                  child: messagesState.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: kPractitionerChatPrimaryBlue),
                    ),
                    error: (error, _) => _ErrorView(
                      message: '메시지를 불러오지 못했어요: $error',
                      onRetry: () => ref
                          .read(practitionerChatMessagesNotifierProvider(session.id).notifier)
                          .load(),
                    ),
                    data: (messages) {
                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: kPractitionerChatPrimaryBlue.withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48,
                                  color: kPractitionerChatPrimaryBlue.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '환자와의 상담을\n시작해보세요',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: kPractitionerChatMediumGray,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      _scrollToBottom(animated: false);
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              kPractitionerChatBackground,
                            ],
                            stops: const [0.0, 0.3],
                          ),
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 20.0,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final showAvatar = index == 0 ||
                                messages[index].sender != messages[index - 1].sender;
                            return _ModernPractitionerMessageBubble(
                              message: messages[index],
                              showAvatar: showAvatar,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                _ModernPractitionerChatInputBar(
                  controller: _chatController,
                  onSend: () => _sendMessage(session),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModernPractitionerChatHeader extends ConsumerWidget {
  const _ModernPractitionerChatHeader({required this.session});

  final ChatSession session;

  Future<void> _deleteSession(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채팅방 나가기'),
        content: const Text('정말 이 채팅방을 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('나가기'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final service = ref.read(chatServiceProvider);
      await service.deleteSession(session.id);
      
      if (context.mounted) {
        // 채팅 세션 목록 새로고침
        ref.refresh(chatSessionsProvider);
        
        // 채팅 목록으로 돌아가기
        context.pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('채팅방을 나갔습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('채팅방 나가기에 실패했습니다: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                color: kPractitionerChatDarkGray,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      kPractitionerChatPrimaryBlue,
                      kPractitionerChatPrimaryBlue.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPractitionerChatPrimaryBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '환자 상담',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: kPractitionerChatDarkGray,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session.subject ?? '방문 진료 상담',
                      style: TextStyle(
                        color: kPractitionerChatMediumGray,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: kPractitionerChatDarkGray,
                  size: 20,
                ),
                onSelected: (value) {
                  if (value == 'leave') {
                    _deleteSession(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'leave',
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('채팅방 나가기', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kPractitionerChatPrimaryBlueLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kPractitionerChatPrimaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '상담중',
                      style: TextStyle(
                        color: kPractitionerChatPrimaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernPractitionerMessageBubble extends StatelessWidget {
  const _ModernPractitionerMessageBubble({
    required this.message,
    required this.showAvatar,
  });

  final ChatMessage message;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    // 한의사 관점에서 메시지 표시
    // sender가 'user'이면 환자가 보낸 메시지, 'doctor'이면 한의사가 보낸 메시지
    final bool isFromPatient = message.sender == 'user';
    final alignment = isFromPatient ? MainAxisAlignment.start : MainAxisAlignment.end;
    final bubbleColor = isFromPatient ? Colors.white : kPractitionerChatPrimaryBlue;
    final textColor = isFromPatient ? kPractitionerChatDarkGray : Colors.white;
    final timeFormat = DateFormat('HH:mm');
    final messageTime = message.createdAt.toLocal();

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12.0,
        top: showAvatar ? 0 : 4.0,
      ),
      child: Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isFromPatient && showAvatar)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPractitionerChatBubbleGray,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: kPractitionerChatMediumGray,
                  size: 18,
                ),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isFromPatient ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isFromPatient ? const Radius.circular(4) : const Radius.circular(20),
                      bottomRight: isFromPatient ? const Radius.circular(20) : const Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isFromPatient
                            ? Colors.black.withValues(alpha: 0.08)
                            : kPractitionerChatPrimaryBlue.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        timeFormat.format(messageTime),
                        style: TextStyle(
                          color: kPractitionerChatMediumGray,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    // 읽음/안 읽음 표시 (카카오톡 스타일)
                    if (!isFromPatient)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          message.readAt != null ? '0' : '1',
                          style: TextStyle(
                            color: kPractitionerChatMediumGray,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!isFromPatient && showAvatar)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      kPractitionerChatPrimaryBlue,
                      kPractitionerChatPrimaryBlue.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPractitionerChatPrimaryBlue.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModernPractitionerChatInputBar extends StatefulWidget {
  const _ModernPractitionerChatInputBar({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  State<_ModernPractitionerChatInputBar> createState() => _ModernPractitionerChatInputBarState();
}

class _ModernPractitionerChatInputBarState extends State<_ModernPractitionerChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kPractitionerChatBubbleGray,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add_rounded,
                    color: kPractitionerChatMediumGray,
                    size: 24,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: TextSelectionThemeData(
                      selectionColor: kPractitionerChatPrimaryBlue.withValues(alpha: 0.3),
                      cursorColor: kPractitionerChatPrimaryBlue,
                    ),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(
                      color: kPractitionerChatDarkGray,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                    cursorColor: kPractitionerChatPrimaryBlue,
                    decoration: InputDecoration(
                      hintText: "환자에게 메시지를 입력하세요",
                      hintStyle: TextStyle(
                        color: kPractitionerChatMediumGray.withValues(alpha: 0.6),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: kPractitionerChatBubbleGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) {
                      if (_hasText) {
                        widget.onSend();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: _hasText ? 48 : 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: _hasText
                      ? LinearGradient(
                          colors: [
                            kPractitionerChatPrimaryBlue,
                            kPractitionerChatPrimaryBlue.withValues(alpha: 0.9),
                          ],
                        )
                      : null,
                  color: _hasText ? null : kPractitionerChatBubbleGray,
                  shape: BoxShape.circle,
                  boxShadow: _hasText
                      ? [
                          BoxShadow(
                            color: kPractitionerChatPrimaryBlue.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _hasText ? widget.onSend : null,
                    borderRadius: BorderRadius.circular(40),
                    child: Center(
                      child: Icon(
                        _hasText ? Icons.send_rounded : Icons.mic_rounded,
                        color: _hasText ? Colors.white : kPractitionerChatMediumGray,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: kPractitionerChatDarkGray, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPractitionerChatPrimaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
