import 'slot.dart';
import 'doctor.dart';

class Appointment {
  const Appointment({
    required this.id,
    required this.status,
    required this.doctor,
    required this.slot,
    this.notes,
  });

  final String id;
  final String status;
  final Doctor doctor;
  final Slot slot;
  final String? notes;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      doctor: Doctor.fromJson(json['doctor'] as Map<String, dynamic>),
      slot: Slot.fromJson(json['slot'] as Map<String, dynamic>),
    );
  }
}
