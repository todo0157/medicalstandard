import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/models/chat_session.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/services/chat_service.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatService(apiClient: apiClient);
});

final chatSessionsProvider = FutureProvider<List<ChatSession>>((ref) async {
  final service = ref.watch(chatServiceProvider);
  return service.fetchSessions();
});

/// Returns the most recent session, creating one if none exist.
final activeChatSessionProvider = FutureProvider<ChatSession>((ref) async {
  final service = ref.watch(chatServiceProvider);
  final sessions = await ref.watch(chatSessionsProvider.future);
  if (sessions.isNotEmpty) return sessions.first;
  return service.createSession(subject: '방문 진료 상담');
});

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatMessagesNotifier({
    required ChatService service,
    required String sessionId,
  })  : _service = service,
        _sessionId = sessionId,
        super(const AsyncValue.loading()) {
    load();
  }

  final ChatService _service;
  final String _sessionId;

  Future<void> load() async {
    try {
      final result = await _service.fetchMessages(_sessionId);
      state = AsyncValue.data(result.messages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> send(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;
    final current = state.asData?.value ?? <ChatMessage>[];
    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    state = AsyncValue.data([
      ...current,
      ChatMessage(
        id: tempId,
        sessionId: _sessionId,
        sender: 'user',
        content: trimmed,
        createdAt: DateTime.now(),
      ),
    ]);

    try {
      final saved =
          await _service.sendMessage(sessionId: _sessionId, content: trimmed);
      _replaceMessage(tempId, saved);
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
  ),
);
