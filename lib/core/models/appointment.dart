import 'slot.dart';
import 'doctor.dart';

class Appointment {
  const Appointment({
    required this.id,
    required this.status,
    required this.doctor,
    required this.slot,
    this.appointmentTime,
    this.notes,
  });

  final String id;
  final String status;
  final Doctor doctor;
  final Slot slot;
  final DateTime? appointmentTime; // 사용자가 선택한 정확한 시간대
  final String? notes;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      appointmentTime: json['appointmentTime'] != null
          ? DateTime.parse(json['appointmentTime'] as String).toLocal()
          : null,
      doctor: Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
      slot: Slot.fromJson(json['slot'] as Map<String, dynamic>),
    );
  }
}
