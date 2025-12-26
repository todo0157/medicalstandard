import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_log.freezed.dart';
part 'health_log.g.dart';

@freezed
class HealthLog with _$HealthLog {
  const factory HealthLog({
    required String id,
    required String userAccountId,
    required DateTime date,
    required String mood, // GOOD, SOSO, BAD
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _HealthLog;

  factory HealthLog.fromJson(Map<String, dynamic> json) => _$HealthLogFromJson(json);
}

