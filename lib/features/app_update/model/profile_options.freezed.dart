// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_options.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProfileOptions {
  Duration get updateInterval => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProfileOptionsCopyWith<ProfileOptions> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileOptionsCopyWith<$Res> {
  factory $ProfileOptionsCopyWith(
          ProfileOptions value, $Res Function(ProfileOptions) then) =
      _$ProfileOptionsCopyWithImpl<$Res, ProfileOptions>;
  @useResult
  $Res call({Duration updateInterval});
}

/// @nodoc
class _$ProfileOptionsCopyWithImpl<$Res, $Val extends ProfileOptions>
    implements $ProfileOptionsCopyWith<$Res> {
  _$ProfileOptionsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? updateInterval = null,
  }) {
    return _then(_value.copyWith(
      updateInterval: null == updateInterval
          ? _value.updateInterval
          : updateInterval // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileOptionsImplCopyWith<$Res>
    implements $ProfileOptionsCopyWith<$Res> {
  factory _$$ProfileOptionsImplCopyWith(_$ProfileOptionsImpl value,
          $Res Function(_$ProfileOptionsImpl) then) =
      __$$ProfileOptionsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Duration updateInterval});
}

/// @nodoc
class __$$ProfileOptionsImplCopyWithImpl<$Res>
    extends _$ProfileOptionsCopyWithImpl<$Res, _$ProfileOptionsImpl>
    implements _$$ProfileOptionsImplCopyWith<$Res> {
  __$$ProfileOptionsImplCopyWithImpl(
      _$ProfileOptionsImpl _value, $Res Function(_$ProfileOptionsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? updateInterval = null,
  }) {
    return _then(_$ProfileOptionsImpl(
      updateInterval: null == updateInterval
          ? _value.updateInterval
          : updateInterval // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$ProfileOptionsImpl implements _ProfileOptions {
  const _$ProfileOptionsImpl({required this.updateInterval});

  @override
  final Duration updateInterval;

  @override
  String toString() {
    return 'ProfileOptions(updateInterval: $updateInterval)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileOptionsImpl &&
            (identical(other.updateInterval, updateInterval) ||
                other.updateInterval == updateInterval));
  }

  @override
  int get hashCode => Object.hash(runtimeType, updateInterval);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileOptionsImplCopyWith<_$ProfileOptionsImpl> get copyWith =>
      __$$ProfileOptionsImplCopyWithImpl<_$ProfileOptionsImpl>(
          this, _$identity);
}

abstract class _ProfileOptions implements ProfileOptions {
  const factory _ProfileOptions({required final Duration updateInterval}) =
      _$ProfileOptionsImpl;

  @override
  Duration get updateInterval;
  @override
  @JsonKey(ignore: true)
  _$$ProfileOptionsImplCopyWith<_$ProfileOptionsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
