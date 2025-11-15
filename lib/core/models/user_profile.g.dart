// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      address: json['address'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      idNumber: json['idNumber'] as String?,
      appointmentCount: (json['appointmentCount'] as num?)?.toInt() ?? 0,
      treatmentCount: (json['treatmentCount'] as num?)?.toInt() ?? 0,
      isPractitioner: json['isPractitioner'] as bool? ?? false,
      licenseNumber: json['licenseNumber'] as String?,
      clinicName: json['clinicName'] as String?,
      certificationStatus:
          $enumDecodeNullable(
            _$CertificationStatusEnumMap,
            json['certificationStatus'],
          ) ??
          CertificationStatus.none,
      certificationDate: json['certificationDate'] == null
          ? null
          : DateTime.parse(json['certificationDate'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'gender': _$GenderEnumMap[instance.gender]!,
      'address': instance.address,
      'profileImageUrl': instance.profileImageUrl,
      'phoneNumber': instance.phoneNumber,
      'idNumber': instance.idNumber,
      'appointmentCount': instance.appointmentCount,
      'treatmentCount': instance.treatmentCount,
      'isPractitioner': instance.isPractitioner,
      'licenseNumber': instance.licenseNumber,
      'clinicName': instance.clinicName,
      'certificationStatus':
          _$CertificationStatusEnumMap[instance.certificationStatus]!,
      'certificationDate': instance.certificationDate?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$GenderEnumMap = {Gender.male: 'male', Gender.female: 'female'};

const _$CertificationStatusEnumMap = {
  CertificationStatus.none: 'none',
  CertificationStatus.pending: 'pending',
  CertificationStatus.verified: 'verified',
};
