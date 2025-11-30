// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Address _$AddressFromJson(Map<String, dynamic> json) {
  return _Address.fromJson(json);
}

/// @nodoc
mixin _$Address {
  String get roadAddress => throw _privateConstructorUsedError; // 도로명 주소
  String get jibunAddress => throw _privateConstructorUsedError; // 지번 주소
  String? get englishAddress => throw _privateConstructorUsedError; // 영문 주소
  double get x => throw _privateConstructorUsedError; // 경도
  double get y => throw _privateConstructorUsedError; // 위도
  double get distance => throw _privateConstructorUsedError; // 거리 (미터)
  List<AddressElement> get addressElements =>
      throw _privateConstructorUsedError; // 주소 구성 요소
  String? get detailAddress => throw _privateConstructorUsedError;

  /// Serializes this Address to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressCopyWith<Address> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressCopyWith<$Res> {
  factory $AddressCopyWith(Address value, $Res Function(Address) then) =
      _$AddressCopyWithImpl<$Res, Address>;
  @useResult
  $Res call({
    String roadAddress,
    String jibunAddress,
    String? englishAddress,
    double x,
    double y,
    double distance,
    List<AddressElement> addressElements,
    String? detailAddress,
  });
}

/// @nodoc
class _$AddressCopyWithImpl<$Res, $Val extends Address>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roadAddress = null,
    Object? jibunAddress = null,
    Object? englishAddress = freezed,
    Object? x = null,
    Object? y = null,
    Object? distance = null,
    Object? addressElements = null,
    Object? detailAddress = freezed,
  }) {
    return _then(
      _value.copyWith(
            roadAddress: null == roadAddress
                ? _value.roadAddress
                : roadAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            jibunAddress: null == jibunAddress
                ? _value.jibunAddress
                : jibunAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            englishAddress: freezed == englishAddress
                ? _value.englishAddress
                : englishAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            x: null == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                      as double,
            y: null == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                      as double,
            distance: null == distance
                ? _value.distance
                : distance // ignore: cast_nullable_to_non_nullable
                      as double,
            addressElements: null == addressElements
                ? _value.addressElements
                : addressElements // ignore: cast_nullable_to_non_nullable
                      as List<AddressElement>,
            detailAddress: freezed == detailAddress
                ? _value.detailAddress
                : detailAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddressImplCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$$AddressImplCopyWith(
    _$AddressImpl value,
    $Res Function(_$AddressImpl) then,
  ) = __$$AddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String roadAddress,
    String jibunAddress,
    String? englishAddress,
    double x,
    double y,
    double distance,
    List<AddressElement> addressElements,
    String? detailAddress,
  });
}

/// @nodoc
class __$$AddressImplCopyWithImpl<$Res>
    extends _$AddressCopyWithImpl<$Res, _$AddressImpl>
    implements _$$AddressImplCopyWith<$Res> {
  __$$AddressImplCopyWithImpl(
    _$AddressImpl _value,
    $Res Function(_$AddressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roadAddress = null,
    Object? jibunAddress = null,
    Object? englishAddress = freezed,
    Object? x = null,
    Object? y = null,
    Object? distance = null,
    Object? addressElements = null,
    Object? detailAddress = freezed,
  }) {
    return _then(
      _$AddressImpl(
        roadAddress: null == roadAddress
            ? _value.roadAddress
            : roadAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        jibunAddress: null == jibunAddress
            ? _value.jibunAddress
            : jibunAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        englishAddress: freezed == englishAddress
            ? _value.englishAddress
            : englishAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        x: null == x
            ? _value.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double,
        y: null == y
            ? _value.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double,
        distance: null == distance
            ? _value.distance
            : distance // ignore: cast_nullable_to_non_nullable
                  as double,
        addressElements: null == addressElements
            ? _value._addressElements
            : addressElements // ignore: cast_nullable_to_non_nullable
                  as List<AddressElement>,
        detailAddress: freezed == detailAddress
            ? _value.detailAddress
            : detailAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AddressImpl implements _Address {
  const _$AddressImpl({
    required this.roadAddress,
    required this.jibunAddress,
    this.englishAddress,
    required this.x,
    required this.y,
    this.distance = 0,
    final List<AddressElement> addressElements = const [],
    this.detailAddress,
  }) : _addressElements = addressElements;

  factory _$AddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressImplFromJson(json);

  @override
  final String roadAddress;
  // 도로명 주소
  @override
  final String jibunAddress;
  // 지번 주소
  @override
  final String? englishAddress;
  // 영문 주소
  @override
  final double x;
  // 경도
  @override
  final double y;
  // 위도
  @override
  @JsonKey()
  final double distance;
  // 거리 (미터)
  final List<AddressElement> _addressElements;
  // 거리 (미터)
  @override
  @JsonKey()
  List<AddressElement> get addressElements {
    if (_addressElements is EqualUnmodifiableListView) return _addressElements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_addressElements);
  }

  // 주소 구성 요소
  @override
  final String? detailAddress;

  @override
  String toString() {
    return 'Address(roadAddress: $roadAddress, jibunAddress: $jibunAddress, englishAddress: $englishAddress, x: $x, y: $y, distance: $distance, addressElements: $addressElements, detailAddress: $detailAddress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressImpl &&
            (identical(other.roadAddress, roadAddress) ||
                other.roadAddress == roadAddress) &&
            (identical(other.jibunAddress, jibunAddress) ||
                other.jibunAddress == jibunAddress) &&
            (identical(other.englishAddress, englishAddress) ||
                other.englishAddress == englishAddress) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            const DeepCollectionEquality().equals(
              other._addressElements,
              _addressElements,
            ) &&
            (identical(other.detailAddress, detailAddress) ||
                other.detailAddress == detailAddress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    roadAddress,
    jibunAddress,
    englishAddress,
    x,
    y,
    distance,
    const DeepCollectionEquality().hash(_addressElements),
    detailAddress,
  );

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      __$$AddressImplCopyWithImpl<_$AddressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddressImplToJson(this);
  }
}

abstract class _Address implements Address {
  const factory _Address({
    required final String roadAddress,
    required final String jibunAddress,
    final String? englishAddress,
    required final double x,
    required final double y,
    final double distance,
    final List<AddressElement> addressElements,
    final String? detailAddress,
  }) = _$AddressImpl;

  factory _Address.fromJson(Map<String, dynamic> json) = _$AddressImpl.fromJson;

  @override
  String get roadAddress; // 도로명 주소
  @override
  String get jibunAddress; // 지번 주소
  @override
  String? get englishAddress; // 영문 주소
  @override
  double get x; // 경도
  @override
  double get y; // 위도
  @override
  double get distance; // 거리 (미터)
  @override
  List<AddressElement> get addressElements; // 주소 구성 요소
  @override
  String? get detailAddress;

  /// Create a copy of Address
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AddressElement _$AddressElementFromJson(Map<String, dynamic> json) {
  return _AddressElement.fromJson(json);
}

/// @nodoc
mixin _$AddressElement {
  List<String> get types =>
      throw _privateConstructorUsedError; // 주소 타입 (SIDO, SIGUGUN, etc.)
  String get longName => throw _privateConstructorUsedError; // 전체 이름
  String get shortName => throw _privateConstructorUsedError; // 짧은 이름
  String get code => throw _privateConstructorUsedError;

  /// Serializes this AddressElement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AddressElement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddressElementCopyWith<AddressElement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressElementCopyWith<$Res> {
  factory $AddressElementCopyWith(
    AddressElement value,
    $Res Function(AddressElement) then,
  ) = _$AddressElementCopyWithImpl<$Res, AddressElement>;
  @useResult
  $Res call({
    List<String> types,
    String longName,
    String shortName,
    String code,
  });
}

/// @nodoc
class _$AddressElementCopyWithImpl<$Res, $Val extends AddressElement>
    implements $AddressElementCopyWith<$Res> {
  _$AddressElementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddressElement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? types = null,
    Object? longName = null,
    Object? shortName = null,
    Object? code = null,
  }) {
    return _then(
      _value.copyWith(
            types: null == types
                ? _value.types
                : types // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            longName: null == longName
                ? _value.longName
                : longName // ignore: cast_nullable_to_non_nullable
                      as String,
            shortName: null == shortName
                ? _value.shortName
                : shortName // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddressElementImplCopyWith<$Res>
    implements $AddressElementCopyWith<$Res> {
  factory _$$AddressElementImplCopyWith(
    _$AddressElementImpl value,
    $Res Function(_$AddressElementImpl) then,
  ) = __$$AddressElementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<String> types,
    String longName,
    String shortName,
    String code,
  });
}

/// @nodoc
class __$$AddressElementImplCopyWithImpl<$Res>
    extends _$AddressElementCopyWithImpl<$Res, _$AddressElementImpl>
    implements _$$AddressElementImplCopyWith<$Res> {
  __$$AddressElementImplCopyWithImpl(
    _$AddressElementImpl _value,
    $Res Function(_$AddressElementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AddressElement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? types = null,
    Object? longName = null,
    Object? shortName = null,
    Object? code = null,
  }) {
    return _then(
      _$AddressElementImpl(
        types: null == types
            ? _value._types
            : types // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        longName: null == longName
            ? _value.longName
            : longName // ignore: cast_nullable_to_non_nullable
                  as String,
        shortName: null == shortName
            ? _value.shortName
            : shortName // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AddressElementImpl implements _AddressElement {
  const _$AddressElementImpl({
    required final List<String> types,
    required this.longName,
    required this.shortName,
    this.code = '',
  }) : _types = types;

  factory _$AddressElementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressElementImplFromJson(json);

  final List<String> _types;
  @override
  List<String> get types {
    if (_types is EqualUnmodifiableListView) return _types;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_types);
  }

  // 주소 타입 (SIDO, SIGUGUN, etc.)
  @override
  final String longName;
  // 전체 이름
  @override
  final String shortName;
  // 짧은 이름
  @override
  @JsonKey()
  final String code;

  @override
  String toString() {
    return 'AddressElement(types: $types, longName: $longName, shortName: $shortName, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressElementImpl &&
            const DeepCollectionEquality().equals(other._types, _types) &&
            (identical(other.longName, longName) ||
                other.longName == longName) &&
            (identical(other.shortName, shortName) ||
                other.shortName == shortName) &&
            (identical(other.code, code) || other.code == code));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_types),
    longName,
    shortName,
    code,
  );

  /// Create a copy of AddressElement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressElementImplCopyWith<_$AddressElementImpl> get copyWith =>
      __$$AddressElementImplCopyWithImpl<_$AddressElementImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AddressElementImplToJson(this);
  }
}

abstract class _AddressElement implements AddressElement {
  const factory _AddressElement({
    required final List<String> types,
    required final String longName,
    required final String shortName,
    final String code,
  }) = _$AddressElementImpl;

  factory _AddressElement.fromJson(Map<String, dynamic> json) =
      _$AddressElementImpl.fromJson;

  @override
  List<String> get types; // 주소 타입 (SIDO, SIGUGUN, etc.)
  @override
  String get longName; // 전체 이름
  @override
  String get shortName; // 짧은 이름
  @override
  String get code;

  /// Create a copy of AddressElement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddressElementImplCopyWith<_$AddressElementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
