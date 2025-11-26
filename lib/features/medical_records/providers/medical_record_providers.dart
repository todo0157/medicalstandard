import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/medical_record.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/services/medical_record_service.dart';

final medicalRecordServiceProvider = Provider<MedicalRecordService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MedicalRecordService(apiClient: apiClient);
});

final medicalRecordsProvider = FutureProvider<List<MedicalRecord>>((ref) async {
  final service = ref.watch(medicalRecordServiceProvider);
  return service.fetchRecords();
});

final medicalRecordProvider =
    FutureProvider.family<MedicalRecord, String>((ref, recordId) async {
      final service = ref.watch(medicalRecordServiceProvider);
      return service.fetchRecord(recordId);
    });
