import 'doctor.dart';

class MedicalRecord {
  const MedicalRecord({
    required this.id,
    required this.title,
    this.summary,
    this.prescriptions,
    this.appointmentId,
    required this.doctor,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? summary;
  final String? prescriptions;
  final String? appointmentId;
  final Doctor doctor;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString(),
      prescriptions: json['prescriptions']?.toString(),
      appointmentId: json['appointmentId']?.toString(),
      doctor: Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
