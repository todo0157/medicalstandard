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

// Modern color palette for chat list
const Color kChatListPrimaryGreen = Color(0xFF10B981);
const Color kChatListPrimaryBlue = Color(0xFF3B82F6);
const Color kChatListGray = Color(0xFF6B7280);
const Color kChatListLightGray = Color(0xFFF3F4F6);
const Color kChatListDarkGray = Color(0xFF111827);
const Color kChatListBackground = Color(0xFFF9FAFB);

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
      backgroundColor: kChatListBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        title: Text(
          uiMode == UIMode.practitioner ? '환자 상담 목록' : '채팅 목록',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: kChatListDarkGray,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  kChatListLightGray,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: kChatListPrimaryGreen,
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '채팅 목록을 불러오지 못했어요',
                  style: TextStyle(
                    color: kChatListDarkGray,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(
                    color: kChatListGray,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(chatSessionsProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('다시 시도'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kChatListPrimaryGreen,
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
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
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
                          color: kChatListPrimaryGreen.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 64,
                      color: kChatListPrimaryGreen.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    uiMode == UIMode.practitioner
                        ? '진행 중인 상담이 없습니다'
                        : '채팅 내역이 없습니다',
                    style: TextStyle(
                      color: kChatListDarkGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    uiMode == UIMode.practitioner
                        ? '환자와의 상담을 시작해보세요'
                        : '한의사와 상담을 시작해보세요',
                    style: TextStyle(
                      color: kChatListGray,
                      fontSize: 14,
                    ),
                  ),
                  if (uiMode == UIMode.patient) ...[
                    const SizedBox(height: 32),
                    Builder(
                      builder: (context) => ElevatedButton.icon(
                        onPressed: () => _startConsultation(context, ref),
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('한의사 찾기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kChatListPrimaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(chatSessionsProvider);
            },
            color: kChatListPrimaryGreen,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: sessions.length,
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
                ),
                // 한의사 찾기 버튼 (항상 표시)
                if (uiMode == UIMode.patient)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Builder(
                      builder: (context) => ElevatedButton.icon(
                        onPressed: () => _startConsultation(context, ref),
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('한의사 찾기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kChatListPrimaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
              ],
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
    // lastMessageAt이 있으면 그것을 사용, 없으면 updatedAt 사용
    // UTC 시간을 로컬 시간으로 변환
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
      iconColor = kChatListPrimaryBlue;
      iconBackgroundColor = kChatListPrimaryBlue.withValues(alpha: 0.1);
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
      iconColor = kChatListPrimaryGreen;
      iconBackgroundColor = kChatListPrimaryGreen.withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: kChatListDarkGray,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isToday
                                ? timeFormat.format(displayTime)
                                : dateFormat.format(displayTime),
                            style: TextStyle(
                              color: kChatListGray,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: kChatListGray,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 읽지 않은 메시지 알림 표시
                Builder(
                  builder: (context) {
                    final unreadCount = session.unreadCount;
                    
                    if (kDebugMode) {
                      print('[ChatListItem] unreadCount check:');
                      print('  - session.id: ${session.id}');
                      print('  - session.unreadCount: $unreadCount');
                      print('  - session.unreadCount > 0: ${unreadCount > 0}');
                      print('  - uiMode: $uiMode');
                      print('  - will show badge: ${unreadCount > 0}');
                    }
                    
                    if (unreadCount > 0) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: uiMode == UIMode.practitioner 
                              ? kChatListPrimaryBlue 
                              : kChatListPrimaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: kChatListGray.withValues(alpha: 0.4),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
