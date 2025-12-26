// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthLogImpl _$$HealthLogImplFromJson(Map<String, dynamic> json) =>
    _$HealthLogImpl(
      id: json['id'] as String,
      userAccountId: json['userAccountId'] as String,
      date: DateTime.parse(json['date'] as String),
      mood: json['mood'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$HealthLogImplToJson(_$HealthLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userAccountId': instance.userAccountId,
      'date': instance.date.toIso8601String(),
      'mood': instance.mood,
      'note': instance.note,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
