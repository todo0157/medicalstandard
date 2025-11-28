import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import '../config/app_config.dart';
import '../models/chat_message.dart';

typedef ChatMessageCallback = void Function(ChatMessage message);
typedef ChatConnectionCallback = void Function();

class ChatRealtimeService {
  ChatRealtimeService({
    required this.sessionId,
    required this.token,
    required this.onMessage,
    this.onConnected,
    this.onDisconnected,
  });

  final String sessionId;
  final String token;
  final ChatMessageCallback onMessage;
  final ChatConnectionCallback? onConnected;
  final ChatConnectionCallback? onDisconnected;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  bool get isConnected => _channel != null;

  void connect() {
    if (token.isEmpty) return;
    final uri = Uri.parse(
      '${AppConfig.wsBaseUrl}/ws/chat?sessionId=$sessionId&token=$token',
    );
    _channel = WebSocketChannel.connect(uri);
    _subscription = _channel!.stream.listen(
      _handleEvent,
      onDone: () {
        _disposeInner();
        onDisconnected?.call();
      },
      onError: (_) {
        _disposeInner();
        onDisconnected?.call();
      },
      cancelOnError: true,
    );
    onConnected?.call();
  }

  void _handleEvent(dynamic event) {
    if (event is! String) return;
    try {
      final decoded = jsonDecode(event) as Map<String, dynamic>;
      if (decoded['type'] != 'message') return;
      final data = decoded['data'] as Map<String, dynamic>?;
      if (data == null) return;
      onMessage(ChatMessage.fromJson(data));
    } catch (_) {
      // ignore malformed payloads
    }
  }

  void close() {
    _channel?.sink.close(ws_status.normalClosure);
    _disposeInner();
    onDisconnected?.call();
  }

  void _disposeInner() {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
  }
}

