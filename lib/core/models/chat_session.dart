import 'doctor.dart';

class ChatSession {
  const ChatSession({
    required this.id,
    this.subject,
    this.doctor,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? subject;
  final Doctor? doctor;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id']?.toString() ?? '',
      subject: json['subject']?.toString(),
      doctor: json['doctor'] is Map<String, dynamic>
          ? Doctor.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
