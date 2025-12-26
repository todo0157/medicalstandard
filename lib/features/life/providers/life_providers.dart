import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/health_tip.dart';
import '../../../core/models/health_log.dart';
import '../../../core/services/api_client.dart';
import '../../../core/providers/profile_provider.dart';

part 'life_providers.g.dart';

@riverpod
Future<List<HealthTip>> healthTips(Ref ref, {String? category}) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/contents/tips');
  
  final List<dynamic> data = response['data'] ?? [];
  return data.map((json) => HealthTip.fromJson(json)).toList();
}

@riverpod
Future<HealthTip> healthTipDetail(Ref ref, String id) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/contents/tips/$id');
  
  final data = response['data'];
  return HealthTip.fromJson(data);
}

@riverpod
class HealthLogsNotifier extends _$HealthLogsNotifier {
  @override
  Future<List<HealthLog>> build() async {
    return _fetchLogs();
  }

  Future<List<HealthLog>> _fetchLogs() async {
    final apiClient = ref.watch(apiClientProvider);
    final response = await apiClient.get('/health-logs');
    
    final List<dynamic> data = response['data'] ?? [];
    return data.map((json) => HealthLog.fromJson(json)).toList();
  }

  Future<void> addLog({required String mood, String? note}) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.post('/health-logs', body: {
      'mood': mood,
      'note': note,
    });
    
    // 상태 갱신
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchLogs());
  }
}
