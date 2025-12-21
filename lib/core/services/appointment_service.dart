import '../errors/app_exception.dart';
import '../models/appointment.dart';
import 'api_client.dart';

class AppointmentService {
  AppointmentService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Appointment> createAppointment({
    required String doctorId,
    required String slotId,
    DateTime? appointmentTime, // 사용자가 선택한 정확한 시간대
    String? notes,
  }) async {
    final res = await _apiClient.post(
      '/doctors/appointments',
      body: {
        'doctorId': doctorId,
        'slotId': slotId,
        if (appointmentTime != null) 'appointmentTime': appointmentTime.toUtc().toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    final data = res['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const AppException.server(message: '예약 결과를 받아오지 못했습니다.');
    }
    return Appointment.fromJson(data);
  }

  Future<List<Appointment>> fetchMyAppointments() async {
    final res = await _apiClient.get('/doctors/appointments');
    final list = (res['data'] as List<dynamic>? ?? [])
        .map((item) => Appointment.fromJson(item as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<Appointment> updateAppointment({
    required String appointmentId,
    String? status,
    String? slotId,
    DateTime? appointmentTime,
    String? notes,
  }) async {
    final res = await _apiClient.patch(
      '/doctors/appointments/$appointmentId',
      body: {
        if (status != null) 'status': status,
        if (slotId != null) 'slotId': slotId,
        if (appointmentTime != null) 'appointmentTime': appointmentTime.toUtc().toIso8601String(),
        if (notes != null) 'notes': notes,
      },
    );
    final data = res['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw const AppException.server(message: '예약 정보를 받아오지 못했습니다.');
    }
    return Appointment.fromJson(data);
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await _apiClient.delete('/doctors/appointments/$appointmentId');
  }
}
