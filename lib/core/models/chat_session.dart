import 'package:flutter/foundation.dart';
import 'doctor.dart';

class ChatSession {
  const ChatSession({
    required this.id,
    this.subject,
    this.doctor,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String id;
  final String? subject;
  final Doctor? doctor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final int unreadCount;

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    // 디버깅: 받은 데이터 확인
    if (kDebugMode) {
      print('[ChatSession.fromJson] Parsing session:');
      print('  - id: ${json['id']}');
      print('  - lastMessageAt: ${json['lastMessageAt']}');
      print('  - unreadCount: ${json['unreadCount']}');
    }
    
    DateTime? lastMessageAt;
    if (json['lastMessageAt'] != null) {
      try {
        lastMessageAt = DateTime.parse(json['lastMessageAt'] as String);
      } catch (e) {
        if (kDebugMode) {
          print('[ChatSession.fromJson] Error parsing lastMessageAt: $e');
        }
        lastMessageAt = null;
      }
    }
    
    // unreadCount 파싱 - 여러 타입 지원
    int unreadCount = 0;
    if (json['unreadCount'] != null) {
      if (json['unreadCount'] is int) {
        unreadCount = json['unreadCount'] as int;
      } else if (json['unreadCount'] is num) {
        unreadCount = (json['unreadCount'] as num).toInt();
      } else if (json['unreadCount'] is String) {
        unreadCount = int.tryParse(json['unreadCount'] as String) ?? 0;
      }
    }
    
    if (kDebugMode) {
      print('[ChatSession.fromJson] Parsed:');
      print('  - lastMessageAt: $lastMessageAt');
      print('  - unreadCount (raw): ${json['unreadCount']}');
      print('  - unreadCount (type): ${json['unreadCount'].runtimeType}');
      print('  - unreadCount (parsed): $unreadCount');
    }
    
    return ChatSession(
      id: json['id']?.toString() ?? '',
      subject: json['subject']?.toString(),
      doctor: json['doctor'] is Map<String, dynamic>
          ? Doctor.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastMessageAt: lastMessageAt,
      unreadCount: unreadCount,
    );
  }
}
