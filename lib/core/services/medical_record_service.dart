import '../models/medical_record.dart';
import 'api_client.dart';

class MedicalRecordService {
  MedicalRecordService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<MedicalRecord>> fetchRecords() async {
    final res = await _apiClient.get('/records');
    final data = res['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => MedicalRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MedicalRecord> fetchRecord(String recordId) async {
    final res = await _apiClient.get('/records/$recordId');
    return MedicalRecord.fromJson(res['data'] as Map<String, dynamic>);
  }
}
