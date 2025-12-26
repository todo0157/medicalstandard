// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HealthLog _$HealthLogFromJson(Map<String, dynamic> json) {
  return _HealthLog.fromJson(json);
}

/// @nodoc
mixin _$HealthLog {
  String get id => throw _privateConstructorUsedError;
  String get userAccountId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get mood => throw _privateConstructorUsedError; // GOOD, SOSO, BAD
  String? get note => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this HealthLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthLogCopyWith<HealthLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthLogCopyWith<$Res> {
  factory $HealthLogCopyWith(HealthLog value, $Res Function(HealthLog) then) =
      _$HealthLogCopyWithImpl<$Res, HealthLog>;
  @useResult
  $Res call({
    String id,
    String userAccountId,
    DateTime date,
    String mood,
    String? note,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$HealthLogCopyWithImpl<$Res, $Val extends HealthLog>
    implements $HealthLogCopyWith<$Res> {
  _$HealthLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userAccountId = null,
    Object? date = null,
    Object? mood = null,
    Object? note = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userAccountId: null == userAccountId
                ? _value.userAccountId
                : userAccountId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            mood: null == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as String,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HealthLogImplCopyWith<$Res>
    implements $HealthLogCopyWith<$Res> {
  factory _$$HealthLogImplCopyWith(
    _$HealthLogImpl value,
    $Res Function(_$HealthLogImpl) then,
  ) = __$$HealthLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userAccountId,
    DateTime date,
    String mood,
    String? note,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$HealthLogImplCopyWithImpl<$Res>
    extends _$HealthLogCopyWithImpl<$Res, _$HealthLogImpl>
    implements _$$HealthLogImplCopyWith<$Res> {
  __$$HealthLogImplCopyWithImpl(
    _$HealthLogImpl _value,
    $Res Function(_$HealthLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HealthLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userAccountId = null,
    Object? date = null,
    Object? mood = null,
    Object? note = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$HealthLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userAccountId: null == userAccountId
            ? _value.userAccountId
            : userAccountId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        mood: null == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as String,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthLogImpl implements _HealthLog {
  const _$HealthLogImpl({
    required this.id,
    required this.userAccountId,
    required this.date,
    required this.mood,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$HealthLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthLogImplFromJson(json);

  @override
  final String id;
  @override
  final String userAccountId;
  @override
  final DateTime date;
  @override
  final String mood;
  // GOOD, SOSO, BAD
  @override
  final String? note;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'HealthLog(id: $id, userAccountId: $userAccountId, date: $date, mood: $mood, note: $note, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userAccountId, userAccountId) ||
                other.userAccountId == userAccountId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.note, note) || other.note == note) &&
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
    userAccountId,
    date,
    mood,
    note,
    createdAt,
    updatedAt,
  );

  /// Create a copy of HealthLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthLogImplCopyWith<_$HealthLogImpl> get copyWith =>
      __$$HealthLogImplCopyWithImpl<_$HealthLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthLogImplToJson(this);
  }
}

abstract class _HealthLog implements HealthLog {
  const factory _HealthLog({
    required final String id,
    required final String userAccountId,
    required final DateTime date,
    required final String mood,
    final String? note,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$HealthLogImpl;

  factory _HealthLog.fromJson(Map<String, dynamic> json) =
      _$HealthLogImpl.fromJson;

  @override
  String get id;
  @override
  String get userAccountId;
  @override
  DateTime get date;
  @override
  String get mood; // GOOD, SOSO, BAD
  @override
  String? get note;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of HealthLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthLogImplCopyWith<_$HealthLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
