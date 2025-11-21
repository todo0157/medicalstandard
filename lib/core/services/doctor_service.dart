import '../models/doctor.dart';
import '../models/slot.dart';
import 'api_client.dart';

class DoctorService {
  DoctorService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  final ApiClient _apiClient;

  Future<List<Doctor>> searchDoctors({String? query}) async {
    final q = (query ?? '').trim();
    final res = await _apiClient.get(
      q.isEmpty ? '/doctors' : '/doctors?query=$q',
    );
    final data = res['data'] as List<dynamic>? ?? [];
    return data.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Slot>> getSlots(String doctorId) async {
    final res = await _apiClient.get('/doctors/$doctorId/slots');
    final data = res['data'] as List<dynamic>? ?? [];
    return data.map((e) => Slot.fromJson(e as Map<String, dynamic>)).toList();
  }
}
