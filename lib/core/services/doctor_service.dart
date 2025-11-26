import '../models/doctor.dart';
import '../models/slot.dart';
import 'api_client.dart';

class DoctorService {
  DoctorService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();
  final ApiClient _apiClient;

  Future<List<Doctor>> searchDoctors({
    String? query,
    double? lat,
    double? lng,
    double? radiusKm,
  }) async {
    final q = (query ?? '').trim();
    final params = <String, String>{};
    if (q.isNotEmpty) params['query'] = q;
    if (lat != null && lng != null) {
      params['lat'] = lat.toString();
      params['lng'] = lng.toString();
      if (radiusKm != null) params['radiusKm'] = radiusKm.toString();
    }
    final queryString = params.entries.isEmpty
        ? ''
        : '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');

    final res = await _apiClient.get('/doctors$queryString');
    final data = res['data'] as List<dynamic>? ?? [];
    return data.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Slot>> getSlots(String doctorId) async {
    final res = await _apiClient.get('/doctors/$doctorId/slots');
    final data = res['data'] as List<dynamic>? ?? [];
    return data.map((e) => Slot.fromJson(e as Map<String, dynamic>)).toList();
  }
}
