import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/models/chat_session.dart';
import '../../../core/services/auth_session.dart';
import '../../../core/services/chat_realtime_service.dart';
import '../providers/chat_providers.dart';

// 디자인 시스템 import
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_shadows.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.sessionId});

  final String? sessionId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
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
        .read(chatMessagesNotifierProvider(session.id).notifier)
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
            .read(chatMessagesNotifierProvider(session.id).notifier)
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
        backgroundColor: AppColors.scaffoldBackground,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(title: const Text('채팅')),
        body: _ErrorView(
          message: '채팅 세션을 불러오지 못했어요: $error',
          onRetry: () => ref.refresh(activeChatSessionProvider),
        ),
      ),
      data: (session) {
        _ensureRealtime(session);
        final messagesState = ref.watch(chatMessagesNotifierProvider(session.id));

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: _buildAppBar(context, ref, session),
          body: Column(
            children: [
              Expanded(
                child: messagesState.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (error, _) => _ErrorView(
                    message: '메시지를 불러오지 못했어요: $error',
                    onRetry: () => ref
                        .read(chatMessagesNotifierProvider(session.id).notifier)
                        .load(),
                  ),
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppSpacing.xl),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: AppShadows.card,
                              ),
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 48,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            SizedBox(height: AppSpacing.lg),
                            Text(
                              '메시지를 입력하여\n상담을 시작해보세요',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }
                    _scrollToBottom(animated: false);
                    
                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                        vertical: AppSpacing.md,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isUser = message.sender == 'user';
                        
                        // 날짜 구분선 표시 여부
                        bool showDateDivider = false;
                        if (index == 0) {
                          showDateDivider = true;
                        } else {
                          final prevMessage = messages[index - 1];
                          final prevDate = prevMessage.createdAt.toLocal();
                          final currDate = message.createdAt.toLocal();
                          if (prevDate.year != currDate.year ||
                              prevDate.month != currDate.month ||
                              prevDate.day != currDate.day) {
                            showDateDivider = true;
                          }
                        }

                        // 아바타/시간 표시 여부 (연속된 메시지 처리)
                        bool showAvatar = true;
                        bool showTime = true;
                        
                        if (index < messages.length - 1) {
                          final nextMessage = messages[index + 1];
                          // 다음 메시지가 같은 사람이 보낸거면 시간 숨김 (1분 이내)
                          if (nextMessage.sender == message.sender) {
                            final currTime = message.createdAt.toLocal();
                            final nextTime = nextMessage.createdAt.toLocal();
                             if (currTime.minute == nextTime.minute && 
                                 currTime.hour == nextTime.hour) {
                               showTime = false;
                             }
                          }
                        }
                        
                        if (index > 0) {
                          final prevMessage = messages[index - 1];
                          // 이전 메시지가 같은 사람이 보낸거면 아바타 숨김
                          if (prevMessage.sender == message.sender) {
                             // 단, 날짜가 바뀌었으면 아바타 다시 표시
                             if (!showDateDivider) {
                               showAvatar = false;
                             }
                          }
                        }

                        return Column(
                          children: [
                            if (showDateDivider) _buildDateDivider(message.createdAt.toLocal()),
                            AppMessageBubble(
                              message: message,
                              isUser: isUser,
                              showAvatar: showAvatar,
                              showTime: showTime,
                              senderName: session.doctor?.name,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              AppChatInput(
                controller: _chatController,
                onSend: () => _sendMessage(session),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, ChatSession session) {
    final doctor = session.doctor;
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.iconPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.subject ?? '방문 진료 상담',
            style: AppTypography.titleMedium,
          ),
          if (doctor != null)
            Text(
              '${doctor.name} 한의사 · ${doctor.specialty}',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert_rounded, color: AppColors.iconPrimary),
          onPressed: () => _showChatOptions(context, ref, session),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(color: AppColors.divider, height: 1),
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.divider)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              DateFormat('yyyy년 M월 d일 EEEE', 'ko').format(date),
              style: AppTypography.caption.copyWith(color: AppColors.textHint),
            ),
          ),
          Expanded(child: Divider(color: AppColors.divider)),
        ],
      ),
    );
  }

  void _showChatOptions(BuildContext context, WidgetRef ref, ChatSession session) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.modalTopRadius),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.exit_to_app_rounded, color: AppColors.error),
              title: Text('채팅방 나가기', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _deleteSession(context, ref, session);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSession(BuildContext context, WidgetRef ref, ChatSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채팅방 나가기'),
        content: const Text('정말 이 채팅방을 나가시겠습니까?\n대화 내용이 모두 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
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
        ref.refresh(chatSessionsProvider);
        context.pop(); // 채팅 화면 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('채팅방을 나갔습니다.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류 발생: ${error.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 시도'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
