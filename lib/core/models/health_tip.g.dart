// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_tip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthTipImpl _$$HealthTipImplFromJson(Map<String, dynamic> json) =>
    _$HealthTipImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String? ?? 'general',
      imageUrl: json['imageUrl'] as String?,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      isVisible: json['isVisible'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$HealthTipImplToJson(_$HealthTipImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'viewCount': instance.viewCount,
      'isVisible': instance.isVisible,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
