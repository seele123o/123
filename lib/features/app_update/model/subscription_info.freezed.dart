// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SubscriptionInfo {
  int get upload => throw _privateConstructorUsedError;
  int get download => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  DateTime get expire => throw _privateConstructorUsedError;
  String? get webPageUrl => throw _privateConstructorUsedError;
  String? get supportUrl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SubscriptionInfoCopyWith<SubscriptionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionInfoCopyWith<$Res> {
  factory $SubscriptionInfoCopyWith(
          SubscriptionInfo value, $Res Function(SubscriptionInfo) then) =
      _$SubscriptionInfoCopyWithImpl<$Res, SubscriptionInfo>;
  @useResult
  $Res call(
      {int upload,
      int download,
      int total,
      DateTime expire,
      String? webPageUrl,
      String? supportUrl});
}

/// @nodoc
class _$SubscriptionInfoCopyWithImpl<$Res, $Val extends SubscriptionInfo>
    implements $SubscriptionInfoCopyWith<$Res> {
  _$SubscriptionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? upload = null,
    Object? download = null,
    Object? total = null,
    Object? expire = null,
    Object? webPageUrl = freezed,
    Object? supportUrl = freezed,
  }) {
    return _then(_value.copyWith(
      upload: null == upload
          ? _value.upload
          : upload // ignore: cast_nullable_to_non_nullable
              as int,
      download: null == download
          ? _value.download
          : download // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      expire: null == expire
          ? _value.expire
          : expire // ignore: cast_nullable_to_non_nullable
              as DateTime,
      webPageUrl: freezed == webPageUrl
          ? _value.webPageUrl
          : webPageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      supportUrl: freezed == supportUrl
          ? _value.supportUrl
          : supportUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionInfoImplCopyWith<$Res>
    implements $SubscriptionInfoCopyWith<$Res> {
  factory _$$SubscriptionInfoImplCopyWith(_$SubscriptionInfoImpl value,
          $Res Function(_$SubscriptionInfoImpl) then) =
      __$$SubscriptionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int upload,
      int download,
      int total,
      DateTime expire,
      String? webPageUrl,
      String? supportUrl});
}

/// @nodoc
class __$$SubscriptionInfoImplCopyWithImpl<$Res>
    extends _$SubscriptionInfoCopyWithImpl<$Res, _$SubscriptionInfoImpl>
    implements _$$SubscriptionInfoImplCopyWith<$Res> {
  __$$SubscriptionInfoImplCopyWithImpl(_$SubscriptionInfoImpl _value,
      $Res Function(_$SubscriptionInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? upload = null,
    Object? download = null,
    Object? total = null,
    Object? expire = null,
    Object? webPageUrl = freezed,
    Object? supportUrl = freezed,
  }) {
    return _then(_$SubscriptionInfoImpl(
      upload: null == upload
          ? _value.upload
          : upload // ignore: cast_nullable_to_non_nullable
              as int,
      download: null == download
          ? _value.download
          : download // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      expire: null == expire
          ? _value.expire
          : expire // ignore: cast_nullable_to_non_nullable
              as DateTime,
      webPageUrl: freezed == webPageUrl
          ? _value.webPageUrl
          : webPageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      supportUrl: freezed == supportUrl
          ? _value.supportUrl
          : supportUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SubscriptionInfoImpl extends _SubscriptionInfo {
  const _$SubscriptionInfoImpl(
      {required this.upload,
      required this.download,
      required this.total,
      required this.expire,
      this.webPageUrl,
      this.supportUrl})
      : super._();

  @override
  final int upload;
  @override
  final int download;
  @override
  final int total;
  @override
  final DateTime expire;
  @override
  final String? webPageUrl;
  @override
  final String? supportUrl;

  @override
  String toString() {
    return 'SubscriptionInfo(upload: $upload, download: $download, total: $total, expire: $expire, webPageUrl: $webPageUrl, supportUrl: $supportUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionInfoImpl &&
            (identical(other.upload, upload) || other.upload == upload) &&
            (identical(other.download, download) ||
                other.download == download) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.expire, expire) || other.expire == expire) &&
            (identical(other.webPageUrl, webPageUrl) ||
                other.webPageUrl == webPageUrl) &&
            (identical(other.supportUrl, supportUrl) ||
                other.supportUrl == supportUrl));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, upload, download, total, expire, webPageUrl, supportUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionInfoImplCopyWith<_$SubscriptionInfoImpl> get copyWith =>
      __$$SubscriptionInfoImplCopyWithImpl<_$SubscriptionInfoImpl>(
          this, _$identity);
}

abstract class _SubscriptionInfo extends SubscriptionInfo {
  const factory _SubscriptionInfo(
      {required final int upload,
      required final int download,
      required final int total,
      required final DateTime expire,
      final String? webPageUrl,
      final String? supportUrl}) = _$SubscriptionInfoImpl;
  const _SubscriptionInfo._() : super._();

  @override
  int get upload;
  @override
  int get download;
  @override
  int get total;
  @override
  DateTime get expire;
  @override
  String? get webPageUrl;
  @override
  String? get supportUrl;
  @override
  @JsonKey(ignore: true)
  _$$SubscriptionInfoImplCopyWith<_$SubscriptionInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
