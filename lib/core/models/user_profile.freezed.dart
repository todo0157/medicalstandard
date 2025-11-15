// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  Gender get gender => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get idNumber => throw _privateConstructorUsedError;
  int get appointmentCount => throw _privateConstructorUsedError;
  int get treatmentCount => throw _privateConstructorUsedError;
  bool get isPractitioner => throw _privateConstructorUsedError;
  String? get licenseNumber => throw _privateConstructorUsedError;
  String? get clinicName => throw _privateConstructorUsedError;
  CertificationStatus get certificationStatus =>
      throw _privateConstructorUsedError;
  DateTime? get certificationDate => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
    UserProfile value,
    $Res Function(UserProfile) then,
  ) = _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call({
    String id,
    String name,
    int age,
    Gender gender,
    String address,
    String? profileImageUrl,
    String? phoneNumber,
    String? idNumber,
    int appointmentCount,
    int treatmentCount,
    bool isPractitioner,
    String? licenseNumber,
    String? clinicName,
    CertificationStatus certificationStatus,
    DateTime? certificationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? age = null,
    Object? gender = null,
    Object? address = null,
    Object? profileImageUrl = freezed,
    Object? phoneNumber = freezed,
    Object? idNumber = freezed,
    Object? appointmentCount = null,
    Object? treatmentCount = null,
    Object? isPractitioner = null,
    Object? licenseNumber = freezed,
    Object? clinicName = freezed,
    Object? certificationStatus = null,
    Object? certificationDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            age: null == age
                ? _value.age
                : age // ignore: cast_nullable_to_non_nullable
                      as int,
            gender: null == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as Gender,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            profileImageUrl: freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            idNumber: freezed == idNumber
                ? _value.idNumber
                : idNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            appointmentCount: null == appointmentCount
                ? _value.appointmentCount
                : appointmentCount // ignore: cast_nullable_to_non_nullable
                      as int,
            treatmentCount: null == treatmentCount
                ? _value.treatmentCount
                : treatmentCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isPractitioner: null == isPractitioner
                ? _value.isPractitioner
                : isPractitioner // ignore: cast_nullable_to_non_nullable
                      as bool,
            licenseNumber: freezed == licenseNumber
                ? _value.licenseNumber
                : licenseNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            clinicName: freezed == clinicName
                ? _value.clinicName
                : clinicName // ignore: cast_nullable_to_non_nullable
                      as String?,
            certificationStatus: null == certificationStatus
                ? _value.certificationStatus
                : certificationStatus // ignore: cast_nullable_to_non_nullable
                      as CertificationStatus,
            certificationDate: freezed == certificationDate
                ? _value.certificationDate
                : certificationDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
    _$UserProfileImpl value,
    $Res Function(_$UserProfileImpl) then,
  ) = __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    int age,
    Gender gender,
    String address,
    String? profileImageUrl,
    String? phoneNumber,
    String? idNumber,
    int appointmentCount,
    int treatmentCount,
    bool isPractitioner,
    String? licenseNumber,
    String? clinicName,
    CertificationStatus certificationStatus,
    DateTime? certificationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
    _$UserProfileImpl _value,
    $Res Function(_$UserProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? age = null,
    Object? gender = null,
    Object? address = null,
    Object? profileImageUrl = freezed,
    Object? phoneNumber = freezed,
    Object? idNumber = freezed,
    Object? appointmentCount = null,
    Object? treatmentCount = null,
    Object? isPractitioner = null,
    Object? licenseNumber = freezed,
    Object? clinicName = freezed,
    Object? certificationStatus = null,
    Object? certificationDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$UserProfileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        age: null == age
            ? _value.age
            : age // ignore: cast_nullable_to_non_nullable
                  as int,
        gender: null == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as Gender,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        profileImageUrl: freezed == profileImageUrl
            ? _value.profileImageUrl
            : profileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        idNumber: freezed == idNumber
            ? _value.idNumber
            : idNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        appointmentCount: null == appointmentCount
            ? _value.appointmentCount
            : appointmentCount // ignore: cast_nullable_to_non_nullable
                  as int,
        treatmentCount: null == treatmentCount
            ? _value.treatmentCount
            : treatmentCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isPractitioner: null == isPractitioner
            ? _value.isPractitioner
            : isPractitioner // ignore: cast_nullable_to_non_nullable
                  as bool,
        licenseNumber: freezed == licenseNumber
            ? _value.licenseNumber
            : licenseNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        clinicName: freezed == clinicName
            ? _value.clinicName
            : clinicName // ignore: cast_nullable_to_non_nullable
                  as String?,
        certificationStatus: null == certificationStatus
            ? _value.certificationStatus
            : certificationStatus // ignore: cast_nullable_to_non_nullable
                  as CertificationStatus,
        certificationDate: freezed == certificationDate
            ? _value.certificationDate
            : certificationDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.address,
    this.profileImageUrl,
    this.phoneNumber,
    this.idNumber,
    this.appointmentCount = 0,
    this.treatmentCount = 0,
    this.isPractitioner = false,
    this.licenseNumber,
    this.clinicName,
    this.certificationStatus = CertificationStatus.none,
    this.certificationDate,
    this.createdAt,
    this.updatedAt,
  });

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int age;
  @override
  final Gender gender;
  @override
  final String address;
  @override
  final String? profileImageUrl;
  @override
  final String? phoneNumber;
  @override
  final String? idNumber;
  @override
  @JsonKey()
  final int appointmentCount;
  @override
  @JsonKey()
  final int treatmentCount;
  @override
  @JsonKey()
  final bool isPractitioner;
  @override
  final String? licenseNumber;
  @override
  final String? clinicName;
  @override
  @JsonKey()
  final CertificationStatus certificationStatus;
  @override
  final DateTime? certificationDate;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, age: $age, gender: $gender, address: $address, profileImageUrl: $profileImageUrl, phoneNumber: $phoneNumber, idNumber: $idNumber, appointmentCount: $appointmentCount, treatmentCount: $treatmentCount, isPractitioner: $isPractitioner, licenseNumber: $licenseNumber, clinicName: $clinicName, certificationStatus: $certificationStatus, certificationDate: $certificationDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.idNumber, idNumber) ||
                other.idNumber == idNumber) &&
            (identical(other.appointmentCount, appointmentCount) ||
                other.appointmentCount == appointmentCount) &&
            (identical(other.treatmentCount, treatmentCount) ||
                other.treatmentCount == treatmentCount) &&
            (identical(other.isPractitioner, isPractitioner) ||
                other.isPractitioner == isPractitioner) &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber) &&
            (identical(other.clinicName, clinicName) ||
                other.clinicName == clinicName) &&
            (identical(other.certificationStatus, certificationStatus) ||
                other.certificationStatus == certificationStatus) &&
            (identical(other.certificationDate, certificationDate) ||
                other.certificationDate == certificationDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    age,
    gender,
    address,
    profileImageUrl,
    phoneNumber,
    idNumber,
    appointmentCount,
    treatmentCount,
    isPractitioner,
    licenseNumber,
    clinicName,
    certificationStatus,
    certificationDate,
    createdAt,
    updatedAt,
  );

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(this);
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile({
    required final String id,
    required final String name,
    required final int age,
    required final Gender gender,
    required final String address,
    final String? profileImageUrl,
    final String? phoneNumber,
    final String? idNumber,
    final int appointmentCount,
    final int treatmentCount,
    final bool isPractitioner,
    final String? licenseNumber,
    final String? clinicName,
    final CertificationStatus certificationStatus,
    final DateTime? certificationDate,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get age;
  @override
  Gender get gender;
  @override
  String get address;
  @override
  String? get profileImageUrl;
  @override
  String? get phoneNumber;
  @override
  String? get idNumber;
  @override
  int get appointmentCount;
  @override
  int get treatmentCount;
  @override
  bool get isPractitioner;
  @override
  String? get licenseNumber;
  @override
  String? get clinicName;
  @override
  CertificationStatus get certificationStatus;
  @override
  DateTime? get certificationDate;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
