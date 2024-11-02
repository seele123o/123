// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_version_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RemoteVersionEntity _$RemoteVersionEntityFromJson(Map<String, dynamic> json) {
  return _RemoteVersionEntity.fromJson(json);
}

/// @nodoc
mixin _$RemoteVersionEntity {
  String get version => throw _privateConstructorUsedError;
  String get releaseNotes => throw _privateConstructorUsedError;
  DateTime get releaseDate => throw _privateConstructorUsedError;
  String get downloadUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RemoteVersionEntityCopyWith<RemoteVersionEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RemoteVersionEntityCopyWith<$Res> {
  factory $RemoteVersionEntityCopyWith(
          RemoteVersionEntity value, $Res Function(RemoteVersionEntity) then) =
      _$RemoteVersionEntityCopyWithImpl<$Res, RemoteVersionEntity>;
  @useResult
  $Res call(
      {String version,
      String releaseNotes,
      DateTime releaseDate,
      String downloadUrl});
}

/// @nodoc
class _$RemoteVersionEntityCopyWithImpl<$Res, $Val extends RemoteVersionEntity>
    implements $RemoteVersionEntityCopyWith<$Res> {
  _$RemoteVersionEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? releaseNotes = null,
    Object? releaseDate = null,
    Object? downloadUrl = null,
  }) {
    return _then(_value.copyWith(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      releaseNotes: null == releaseNotes
          ? _value.releaseNotes
          : releaseNotes // ignore: cast_nullable_to_non_nullable
              as String,
      releaseDate: null == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      downloadUrl: null == downloadUrl
          ? _value.downloadUrl
          : downloadUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RemoteVersionEntityImplCopyWith<$Res>
    implements $RemoteVersionEntityCopyWith<$Res> {
  factory _$$RemoteVersionEntityImplCopyWith(_$RemoteVersionEntityImpl value,
          $Res Function(_$RemoteVersionEntityImpl) then) =
      __$$RemoteVersionEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String version,
      String releaseNotes,
      DateTime releaseDate,
      String downloadUrl});
}

/// @nodoc
class __$$RemoteVersionEntityImplCopyWithImpl<$Res>
    extends _$RemoteVersionEntityCopyWithImpl<$Res, _$RemoteVersionEntityImpl>
    implements _$$RemoteVersionEntityImplCopyWith<$Res> {
  __$$RemoteVersionEntityImplCopyWithImpl(_$RemoteVersionEntityImpl _value,
      $Res Function(_$RemoteVersionEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? version = null,
    Object? releaseNotes = null,
    Object? releaseDate = null,
    Object? downloadUrl = null,
  }) {
    return _then(_$RemoteVersionEntityImpl(
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      releaseNotes: null == releaseNotes
          ? _value.releaseNotes
          : releaseNotes // ignore: cast_nullable_to_non_nullable
              as String,
      releaseDate: null == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      downloadUrl: null == downloadUrl
          ? _value.downloadUrl
          : downloadUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RemoteVersionEntityImpl implements _RemoteVersionEntity {
  const _$RemoteVersionEntityImpl(
      {required this.version,
      required this.releaseNotes,
      required this.releaseDate,
      required this.downloadUrl});

  factory _$RemoteVersionEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$RemoteVersionEntityImplFromJson(json);

  @override
  final String version;
  @override
  final String releaseNotes;
  @override
  final DateTime releaseDate;
  @override
  final String downloadUrl;

  @override
  String toString() {
    return 'RemoteVersionEntity(version: $version, releaseNotes: $releaseNotes, releaseDate: $releaseDate, downloadUrl: $downloadUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoteVersionEntityImpl &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.releaseNotes, releaseNotes) ||
                other.releaseNotes == releaseNotes) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, version, releaseNotes, releaseDate, downloadUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RemoteVersionEntityImplCopyWith<_$RemoteVersionEntityImpl> get copyWith =>
      __$$RemoteVersionEntityImplCopyWithImpl<_$RemoteVersionEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RemoteVersionEntityImplToJson(
      this,
    );
  }
}

abstract class _RemoteVersionEntity implements RemoteVersionEntity {
  const factory _RemoteVersionEntity(
      {required final String version,
      required final String releaseNotes,
      required final DateTime releaseDate,
      required final String downloadUrl}) = _$RemoteVersionEntityImpl;

  factory _RemoteVersionEntity.fromJson(Map<String, dynamic> json) =
      _$RemoteVersionEntityImpl.fromJson;

  @override
  String get version;
  @override
  String get releaseNotes;
  @override
  DateTime get releaseDate;
  @override
  String get downloadUrl;
  @override
  @JsonKey(ignore: true)
  _$$RemoteVersionEntityImplCopyWith<_$RemoteVersionEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
