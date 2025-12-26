import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_tip.freezed.dart';
part 'health_tip.g.dart';

@freezed
class HealthTip with _$HealthTip {
  const factory HealthTip({
    required String id,
    required String title,
    required String content,
    @Default('general') String category,
    String? imageUrl,
    @Default(0) int viewCount,
    @Default(true) bool isVisible,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _HealthTip;

  factory HealthTip.fromJson(Map<String, dynamic> json) => _$HealthTipFromJson(json);
}
