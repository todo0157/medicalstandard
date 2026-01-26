import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/chat_session.dart';
import '../../../core/models/doctor.dart';
import '../../../core/providers/ui_mode_provider.dart';
import '../providers/chat_providers.dart';
import 'chat_screen.dart';
import 'practitioner_chat_screen.dart';
import '../../doctor/screens/find_doctor_screen.dart';

// 디자인 시스템 import (Phase 1)
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_radius.dart';
import '../../../shared/theme/app_shadows.dart';
import '../../../shared/widgets/common_badge.dart';
import '../../../shared/widgets/common_button.dart';
import '../../../shared/widgets/common_card.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 앱이 다시 활성화될 때 채팅 목록 새로고침
      ref.refresh(chatSessionsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ChatListContent();
  }
}

class _ChatListContent extends ConsumerStatefulWidget {
  const _ChatListContent();

  @override
  ConsumerState<_ChatListContent> createState() => _ChatListContentState();
}

class _ChatListContentState extends ConsumerState<_ChatListContent> with WidgetsBindingObserver {
  Timer? _refreshTimer;
  bool _isScreenActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isScreenActive) {
      // 앱이 다시 활성화되고 화면이 활성화되어 있을 때만 새로고침
      ref.refresh(chatSessionsProvider);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 활성화되었는지 확인
    final modalRoute = ModalRoute.of(context);
    final wasActive = _isScreenActive;
    _isScreenActive = modalRoute?.isCurrent ?? false;
    
    // 화면이 활성화되었을 때만 새로고침 시작
    if (_isScreenActive && !wasActive) {
      // 화면이 활성화될 때 즉시 새로고침
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.refresh(chatSessionsProvider);
        }
      });
      
      // 10초마다 자동 새로고침 시작
      _refreshTimer?.cancel();
      _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (mounted && _isScreenActive) {
          ref.refresh(chatSessionsProvider);
        }
      });
    } else if (!_isScreenActive && wasActive) {
      // 화면이 비활성화되면 자동 새로고침 중지
      _refreshTimer?.cancel();
      _refreshTimer = null;
    }
  }


  Future<void> _startConsultation(BuildContext context, WidgetRef ref) async {
    // 한의사 찾기 화면으로 이동하고 선택된 한의사 받기
    final selectedDoctor = await context.push<Doctor>('/find-doctor');
    if (selectedDoctor != null && context.mounted) {
      // 선택된 한의사와의 상담 시작
      await _createChatSessionAndNavigate(context, ref, selectedDoctor);
    }
  }

  Future<void> _createChatSessionAndNavigate(
    BuildContext context,
    WidgetRef ref,
    Doctor doctor,
  ) async {
    try {
      // 채팅 세션 생성
      final service = ref.read(chatServiceProvider);
      final session = await service.createSession(
        doctorId: doctor.id,
        subject: '${doctor.name} 한의사 상담',
      );
      
      if (context.mounted) {
        // 채팅 세션 목록 새로고침
        ref.refresh(chatSessionsProvider);
        
        // 채팅 화면으로 이동
        context.push('/chat/${session.id}');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('상담을 시작하지 못했습니다: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSession(
    BuildContext context,
    WidgetRef ref,
    String sessionId,
  ) async {
    // 삭제 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채팅방 삭제'),
        content: const Text('정말 이 채팅방을 삭제하시겠습니까?'),
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
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final service = ref.read(chatServiceProvider);
      await service.deleteSession(sessionId);
      
      if (context.mounted) {
        // 채팅 세션 목록 새로고침
        ref.refresh(chatSessionsProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('채팅방이 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('채팅방 삭제에 실패했습니다: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiMode = ref.watch(uiModeProvider);
    final sessionsAsync = ref.watch(chatSessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        title: Text(
          uiMode == UIMode.practitioner ? '환자 상담 목록' : '채팅 목록',
          style: AppTypography.titleMedium,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.divider,
          ),
        ),
      ),
      floatingActionButton: uiMode == UIMode.patient
          ? FloatingActionButton.extended(
              onPressed: () => _startConsultation(context, ref),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('새 상담'),
            )
          : null,
      body: sessionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: AppSpacing.screenPaddingAll,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  '채팅 목록을 불러오지 못했어요',
                  style: AppTypography.headingMedium,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  error.toString(),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  onPressed: () => ref.refresh(chatSessionsProvider),
                  text: '다시 시도',
                  icon: Icons.refresh_rounded,
                  size: ButtonSize.medium,
                  isFullWidth: false,
                ),
              ],
            ),
          ),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: AppSpacing.screenPaddingAll,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 64,
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    Text(
                      uiMode == UIMode.practitioner
                          ? '진행 중인 상담이 없습니다'
                          : '채팅 내역이 없습니다',
                      style: AppTypography.titleMedium,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      uiMode == UIMode.practitioner
                          ? '환자와의 상담을 시작하면\n여기에 채팅 목록이 표시됩니다'
                          : '한의사와 상담을 시작해보세요\n24시간 언제든지 문의할 수 있습니다',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (uiMode == UIMode.patient) ...[
                      SizedBox(height: AppSpacing.xl),
                      AppBrandButton(
                        onPressed: () => _startConsultation(context, ref),
                        text: '한의사 찾기',
                        icon: Icons.search_rounded,
                        isFullWidth: false,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(chatSessionsProvider);
            },
            color: AppColors.primary,
            child: ListView.separated(
              padding: AppSpacing.screenPaddingAll,
              itemCount: sessions.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _ModernChatListItem(
                  session: session,
                  uiMode: uiMode,
                  onTap: () {
                    if (uiMode == UIMode.practitioner) {
                      context.push('/practitioner-chat/${session.id}');
                    } else {
                      context.push('/chat/${session.id}');
                    }
                  },
                  onDelete: () => _deleteSession(context, ref, session.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ModernChatListItem extends StatelessWidget {
  const _ModernChatListItem({
    required this.session,
    required this.uiMode,
    required this.onTap,
    this.onDelete,
  });

  final ChatSession session;
  final UIMode uiMode;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM월 dd일', 'ko_KR');
    final timeFormat = DateFormat('HH:mm', 'ko_KR');
    final displayTime = (session.lastMessageAt ?? session.updatedAt).toLocal();
    final now = DateTime.now();
    final isToday = displayTime.year == now.year &&
        displayTime.month == now.month &&
        displayTime.day == now.day;

    // 디버깅: 표시할 시간과 읽지 않은 메시지 수 확인
    if (kDebugMode) {
      print('[ChatListItem] Session: ${session.id}');
      print('  - lastMessageAt (UTC): ${session.lastMessageAt}');
      print('  - lastMessageAt (Local): ${session.lastMessageAt?.toLocal()}');
      print('  - updatedAt (UTC): ${session.updatedAt}');
      print('  - updatedAt (Local): ${session.updatedAt.toLocal()}');
      print('  - displayTime (Local): $displayTime');
      print('  - unreadCount: ${session.unreadCount}');
    }

    String displayName;
    String? subtitle;
    IconData iconData;
    Color iconColor;
    Color iconBackgroundColor;

    if (uiMode == UIMode.practitioner) {
      // 한의사 모드: 환자 정보 표시
      displayName = '환자';
      subtitle = session.subject ?? '방문 진료 상담';
      iconData = Icons.person_rounded;
      iconColor = AppColors.primary;
      iconBackgroundColor = AppColors.primaryLight;
    } else {
      // 환자 모드: 한의사 정보 표시
      if (session.doctor != null) {
        displayName = session.doctor!.name;
        subtitle = '${session.doctor!.name} · ${session.doctor!.specialty}';
      } else {
        displayName = '의료진';
        subtitle = session.subject ?? '방문 진료 상담';
      }
      iconData = Icons.health_and_safety_rounded;
      iconColor = AppColors.secondary;
      iconBackgroundColor = AppColors.secondaryLight;
    }

    return AppBaseCard(
      onTap: onTap,
      margin: EdgeInsets.zero,
      padding: AppSpacing.cardPaddingAll,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBackgroundColor,
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 28,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: AppTypography.headingLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      isToday
                          ? timeFormat.format(displayTime)
                          : dateFormat.format(displayTime),
                      style: AppTypography.chatTimeText.copyWith(
                        color: session.unreadCount > 0
                            ? AppColors.primary
                            : AppColors.textHint,
                        fontWeight: session.unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle ?? '',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: session.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (session.unreadCount > 0) ...[
                      SizedBox(width: AppSpacing.xs),
                      AppCountBadge(
                        count: session.unreadCount,
                        color: uiMode == UIMode.practitioner
                            ? AppColors.primary
                            : AppColors.secondary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.iconSecondary.withOpacity(0.5),
            size: 24,
          ),
        ],
      ),
    );
  }
}
