// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_process_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PaymentProcessState {
  PaymentStep get currentStep => throw _privateConstructorUsedError;
  bool get isProcessing => throw _privateConstructorUsedError;
  String? get orderId => throw _privateConstructorUsedError;
  double? get amount => throw _privateConstructorUsedError;
  String? get selectedMethod => throw _privateConstructorUsedError;
  Map<String, dynamic>? get paymentData => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  DateTime? get lastUpdate => throw _privateConstructorUsedError;
  PaymentException? get lastException => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PaymentProcessStateCopyWith<PaymentProcessState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentProcessStateCopyWith<$Res> {
  factory $PaymentProcessStateCopyWith(
          PaymentProcessState value, $Res Function(PaymentProcessState) then) =
      _$PaymentProcessStateCopyWithImpl<$Res, PaymentProcessState>;
  @useResult
  $Res call(
      {PaymentStep currentStep,
      bool isProcessing,
      String? orderId,
      double? amount,
      String? selectedMethod,
      Map<String, dynamic>? paymentData,
      String? error,
      double progress,
      DateTime? lastUpdate,
      PaymentException? lastException});
}

/// @nodoc
class _$PaymentProcessStateCopyWithImpl<$Res, $Val extends PaymentProcessState>
    implements $PaymentProcessStateCopyWith<$Res> {
  _$PaymentProcessStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? isProcessing = null,
    Object? orderId = freezed,
    Object? amount = freezed,
    Object? selectedMethod = freezed,
    Object? paymentData = freezed,
    Object? error = freezed,
    Object? progress = null,
    Object? lastUpdate = freezed,
    Object? lastException = freezed,
  }) {
    return _then(_value.copyWith(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as PaymentStep,
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      selectedMethod: freezed == selectedMethod
          ? _value.selectedMethod
          : selectedMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentData: freezed == paymentData
          ? _value.paymentData
          : paymentData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      lastUpdate: freezed == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastException: freezed == lastException
          ? _value.lastException
          : lastException // ignore: cast_nullable_to_non_nullable
              as PaymentException?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaymentProcessStateImplCopyWith<$Res>
    implements $PaymentProcessStateCopyWith<$Res> {
  factory _$$PaymentProcessStateImplCopyWith(_$PaymentProcessStateImpl value,
          $Res Function(_$PaymentProcessStateImpl) then) =
      __$$PaymentProcessStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PaymentStep currentStep,
      bool isProcessing,
      String? orderId,
      double? amount,
      String? selectedMethod,
      Map<String, dynamic>? paymentData,
      String? error,
      double progress,
      DateTime? lastUpdate,
      PaymentException? lastException});
}

/// @nodoc
class __$$PaymentProcessStateImplCopyWithImpl<$Res>
    extends _$PaymentProcessStateCopyWithImpl<$Res, _$PaymentProcessStateImpl>
    implements _$$PaymentProcessStateImplCopyWith<$Res> {
  __$$PaymentProcessStateImplCopyWithImpl(_$PaymentProcessStateImpl _value,
      $Res Function(_$PaymentProcessStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? isProcessing = null,
    Object? orderId = freezed,
    Object? amount = freezed,
    Object? selectedMethod = freezed,
    Object? paymentData = freezed,
    Object? error = freezed,
    Object? progress = null,
    Object? lastUpdate = freezed,
    Object? lastException = freezed,
  }) {
    return _then(_$PaymentProcessStateImpl(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as PaymentStep,
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      selectedMethod: freezed == selectedMethod
          ? _value.selectedMethod
          : selectedMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentData: freezed == paymentData
          ? _value._paymentData
          : paymentData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      lastUpdate: freezed == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastException: freezed == lastException
          ? _value.lastException
          : lastException // ignore: cast_nullable_to_non_nullable
              as PaymentException?,
    ));
  }
}

/// @nodoc

class _$PaymentProcessStateImpl extends _PaymentProcessState
    with DiagnosticableTreeMixin {
  const _$PaymentProcessStateImpl(
      {this.currentStep = PaymentStep.initial,
      this.isProcessing = false,
      this.orderId,
      this.amount,
      this.selectedMethod,
      final Map<String, dynamic>? paymentData,
      this.error,
      this.progress = 0.0,
      this.lastUpdate,
      this.lastException})
      : _paymentData = paymentData,
        super._();

  @override
  @JsonKey()
  final PaymentStep currentStep;
  @override
  @JsonKey()
  final bool isProcessing;
  @override
  final String? orderId;
  @override
  final double? amount;
  @override
  final String? selectedMethod;
  final Map<String, dynamic>? _paymentData;
  @override
  Map<String, dynamic>? get paymentData {
    final value = _paymentData;
    if (value == null) return null;
    if (_paymentData is EqualUnmodifiableMapView) return _paymentData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? error;
  @override
  @JsonKey()
  final double progress;
  @override
  final DateTime? lastUpdate;
  @override
  final PaymentException? lastException;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PaymentProcessState(currentStep: $currentStep, isProcessing: $isProcessing, orderId: $orderId, amount: $amount, selectedMethod: $selectedMethod, paymentData: $paymentData, error: $error, progress: $progress, lastUpdate: $lastUpdate, lastException: $lastException)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'PaymentProcessState'))
      ..add(DiagnosticsProperty('currentStep', currentStep))
      ..add(DiagnosticsProperty('isProcessing', isProcessing))
      ..add(DiagnosticsProperty('orderId', orderId))
      ..add(DiagnosticsProperty('amount', amount))
      ..add(DiagnosticsProperty('selectedMethod', selectedMethod))
      ..add(DiagnosticsProperty('paymentData', paymentData))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('progress', progress))
      ..add(DiagnosticsProperty('lastUpdate', lastUpdate))
      ..add(DiagnosticsProperty('lastException', lastException));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentProcessStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.selectedMethod, selectedMethod) ||
                other.selectedMethod == selectedMethod) &&
            const DeepCollectionEquality()
                .equals(other._paymentData, _paymentData) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.lastUpdate, lastUpdate) ||
                other.lastUpdate == lastUpdate) &&
            const DeepCollectionEquality()
                .equals(other.lastException, lastException));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStep,
      isProcessing,
      orderId,
      amount,
      selectedMethod,
      const DeepCollectionEquality().hash(_paymentData),
      error,
      progress,
      lastUpdate,
      const DeepCollectionEquality().hash(lastException));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentProcessStateImplCopyWith<_$PaymentProcessStateImpl> get copyWith =>
      __$$PaymentProcessStateImplCopyWithImpl<_$PaymentProcessStateImpl>(
          this, _$identity);
}

abstract class _PaymentProcessState extends PaymentProcessState {
  const factory _PaymentProcessState(
      {final PaymentStep currentStep,
      final bool isProcessing,
      final String? orderId,
      final double? amount,
      final String? selectedMethod,
      final Map<String, dynamic>? paymentData,
      final String? error,
      final double progress,
      final DateTime? lastUpdate,
      final PaymentException? lastException}) = _$PaymentProcessStateImpl;
  const _PaymentProcessState._() : super._();

  @override
  PaymentStep get currentStep;
  @override
  bool get isProcessing;
  @override
  String? get orderId;
  @override
  double? get amount;
  @override
  String? get selectedMethod;
  @override
  Map<String, dynamic>? get paymentData;
  @override
  String? get error;
  @override
  double get progress;
  @override
  DateTime? get lastUpdate;
  @override
  PaymentException? get lastException;
  @override
  @JsonKey(ignore: true)
  _$$PaymentProcessStateImplCopyWith<_$PaymentProcessStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
