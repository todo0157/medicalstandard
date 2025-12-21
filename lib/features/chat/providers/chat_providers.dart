import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/models/chat_session.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/ui_mode_provider.dart';
import '../../../core/services/chat_service.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatService(apiClient: apiClient);
});

/// UI 모드에 따라 채팅 세션 목록을 가져옵니다.
/// - 환자 모드: 환자가 생성한 세션, 한의사가 보낸 읽지 않은 메시지 수
/// - 한의사 모드: 한의사에게 온 세션, 환자가 보낸 읽지 않은 메시지 수
final chatSessionsProvider = FutureProvider<List<ChatSession>>((ref) async {
  final service = ref.watch(chatServiceProvider);
  final uiMode = ref.watch(uiModeProvider);
  final isPractitionerMode = uiMode == UIMode.practitioner;
  return service.fetchSessions(isPractitionerMode: isPractitionerMode);
});

/// Returns the most recent session, creating one if none exist.
final activeChatSessionProvider = FutureProvider<ChatSession>((ref) async {
  final service = ref.watch(chatServiceProvider);
  final sessions = await ref.watch(chatSessionsProvider.future);
  if (sessions.isNotEmpty) return sessions.first;
  return service.createSession(subject: '방문 진료 상담');
});

/// Returns a specific session by ID
final chatSessionByIdProvider = FutureProvider.autoDispose.family<ChatSession, String>((ref, sessionId) async {
  final service = ref.watch(chatServiceProvider);
  final sessions = await ref.watch(chatSessionsProvider.future);
  final session = sessions.firstWhere(
    (s) => s.id == sessionId,
    orElse: () => throw Exception('Session not found'),
  );
  return session;
});

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatMessagesNotifier({
    required ChatService service,
    required String sessionId,
    this.isPractitionerMode = false,
  })  : _service = service,
        _sessionId = sessionId,
        super(const AsyncValue.loading()) {
    load();
  }

  final ChatService _service;
  final String _sessionId;
  final bool isPractitionerMode;

  Future<void> load() async {
    try {
      final result = await _service.fetchMessages(_sessionId, isPractitionerMode: isPractitionerMode);
      state = AsyncValue.data(result.messages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> send(String content, {void Function()? onSent}) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    final current = state.asData?.value ?? <ChatMessage>[];
    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    
    // 임시 메시지는 sender를 설정하지 않고, 서버 응답을 기다립니다
    // 서버가 올바른 sender를 반환하므로 임시 메시지의 sender는 중요하지 않습니다
    // 하지만 UI 일관성을 위해 임시로 'user'로 설정 (서버 응답으로 즉시 교체됨)
    state = AsyncValue.data([
      ...current,
      ChatMessage(
        id: tempId,
        sessionId: _sessionId,
        sender: 'user', // 임시 값, 서버 응답으로 교체됨
        content: trimmed,
        createdAt: DateTime.now(),
      ),
    ]);

    try {
      final saved = await _service.sendMessage(
        sessionId: _sessionId,
        content: trimmed,
        isPractitionerMode: isPractitionerMode,
      );
      // 서버에서 받은 메시지로 교체 (올바른 sender 포함)
      _replaceMessage(tempId, saved);
      // 메시지 전송 후 콜백 실행 (채팅 목록 새로고침 등)
      onSent?.call();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void addRealtimeMessage(ChatMessage message) {
    final current = state.asData?.value ?? <ChatMessage>[];
    final alreadyExists = current.any((item) => item.id == message.id);
    if (alreadyExists) return;
    final updated = [...current, message]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    state = AsyncValue.data(updated);
  }

  void _replaceMessage(String tempId, ChatMessage saved) {
    final current = state.asData?.value ?? <ChatMessage>[];
    final updated = current
        .map((item) => item.id == tempId ? saved : item)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    state = AsyncValue.data(updated);
  }
}

final chatMessagesNotifierProvider = StateNotifierProvider.autoDispose
    .family<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>, String>(
  (ref, sessionId) => ChatMessagesNotifier(
    service: ref.watch(chatServiceProvider),
    sessionId: sessionId,
    isPractitionerMode: false, // 기본값은 환자 모드
  ),
);

final practitionerChatMessagesNotifierProvider = StateNotifierProvider.autoDispose
    .family<ChatMessagesNotifier, AsyncValue<List<ChatMessage>>, String>(
  (ref, sessionId) => ChatMessagesNotifier(
    service: ref.watch(chatServiceProvider),
    sessionId: sessionId,
    isPractitionerMode: true, // 한의사 모드
  ),
);
