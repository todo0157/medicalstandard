// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AddressImpl _$$AddressImplFromJson(Map<String, dynamic> json) =>
    _$AddressImpl(
      roadAddress: json['roadAddress'] as String,
      jibunAddress: json['jibunAddress'] as String,
      englishAddress: json['englishAddress'] as String?,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      addressElements:
          (json['addressElements'] as List<dynamic>?)
              ?.map((e) => AddressElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      detailAddress: json['detailAddress'] as String?,
    );

Map<String, dynamic> _$$AddressImplToJson(_$AddressImpl instance) =>
    <String, dynamic>{
      'roadAddress': instance.roadAddress,
      'jibunAddress': instance.jibunAddress,
      'englishAddress': instance.englishAddress,
      'x': instance.x,
      'y': instance.y,
      'distance': instance.distance,
      'addressElements': instance.addressElements,
      'detailAddress': instance.detailAddress,
    };

_$AddressElementImpl _$$AddressElementImplFromJson(Map<String, dynamic> json) =>
    _$AddressElementImpl(
      types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
      longName: json['longName'] as String,
      shortName: json['shortName'] as String,
      code: json['code'] as String? ?? '',
    );

Map<String, dynamic> _$$AddressElementImplToJson(
  _$AddressElementImpl instance,
) => <String, dynamic>{
  'types': instance.types,
  'longName': instance.longName,
  'shortName': instance.shortName,
  'code': instance.code,
};
