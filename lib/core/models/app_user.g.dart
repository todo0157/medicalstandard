// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      authProvider: $enumDecode(_$AuthProviderEnumMap, json['authProvider']),
      profile: UserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      isEmailVerified: json['isEmailVerified'] as bool,
      isPhoneVerified: json['isPhoneVerified'] as bool,
      lastLogin: json['lastLogin'] == null
          ? null
          : DateTime.parse(json['lastLogin'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'authProvider': _$AuthProviderEnumMap[instance.authProvider]!,
      'profile': instance.profile,
      'isEmailVerified': instance.isEmailVerified,
      'isPhoneVerified': instance.isPhoneVerified,
      'lastLogin': instance.lastLogin?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$AuthProviderEnumMap = {
  AuthProvider.kakao: 'kakao',
  AuthProvider.pass: 'pass',
  AuthProvider.manual: 'manual',
};
