import '../models/chat_message.dart';
import '../models/chat_session.dart';
import 'api_client.dart';

class ChatMessagesResult {
  const ChatMessagesResult({required this.session, required this.messages});
  final ChatSession session;
  final List<ChatMessage> messages;
}

class ChatService {
  ChatService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ChatSession>> fetchSessions() async {
    final res = await _apiClient.get('/chat/sessions');
    final data = res['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => ChatSession.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ChatSession> createSession({String? doctorId, String? subject}) async {
    final res = await _apiClient.post(
      '/chat/sessions',
      body: {
        if (doctorId != null) 'doctorId': doctorId,
        if (subject != null && subject.isNotEmpty) 'subject': subject,
      },
    );
    return ChatSession.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<ChatMessagesResult> fetchMessages(String sessionId) async {
    final res = await _apiClient.get('/chat/sessions/$sessionId/messages');
    final data = res['data'] as Map<String, dynamic>? ?? {};
    final session = ChatSession.fromJson(
      data['session'] as Map<String, dynamic>,
    );
    final messages = (data['messages'] as List<dynamic>? ?? [])
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();
    return ChatMessagesResult(session: session, messages: messages);
  }

  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    final res = await _apiClient.post(
      '/chat/sessions/$sessionId/messages',
      body: {'content': content},
    );
    return ChatMessage.fromJson(res['data'] as Map<String, dynamic>);
  }
}
