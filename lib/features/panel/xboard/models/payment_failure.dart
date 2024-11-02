// lib/features/panel/xboard/model/payment_failure.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/localization/translations.dart';

part 'payment_failure.freezed.dart';

@freezed
sealed class PaymentFailure with _$PaymentFailure, Failure {
  const PaymentFailure._();

  @With<UnexpectedFailure>()
  const factory PaymentFailure.unexpected([
    Object? error,
    StackTrace? stackTrace,
  ]) = PaymentUnexpectedFailure;

  const factory PaymentFailure.invalidAmount() = PaymentInvalidAmountFailure;

  const factory PaymentFailure.paymentCancelled() = PaymentCancelledFailure;

  const factory PaymentFailure.paymentFailed([String? message]) = PaymentFailedFailure;

  const factory PaymentFailure.paymentTimeout() = PaymentTimeoutFailure;

  const factory PaymentFailure.providerUnavailable() = PaymentProviderUnavailableFailure;

  const factory PaymentFailure.networkError() = PaymentNetworkFailure;

  const factory PaymentFailure.invalidConfig() = PaymentInvalidConfigFailure;

  const factory PaymentFailure.subscriptionNotFound() = SubscriptionNotFoundFailure;

  const factory PaymentFailure.subscriptionExpired() = SubscriptionExpiredFailure;

  @override
  ({String type, String? message}) present(TranslationsEn t) {
    return switch (this) {
      PaymentUnexpectedFailure() => (
          type: t.failure.unexpected,
          message: null,
        ),
      PaymentInvalidAmountFailure() => (
          type: t.payment.error.invalidAmount,
          message: null,
        ),
      PaymentCancelledFailure() => (
          type: t.payment.error.cancelled,
          message: null,
        ),
      PaymentFailedFailure(:final message) => (
          type: t.payment.error.failed,
          message: message,
        ),
      PaymentTimeoutFailure() => (
          type: t.payment.error.timeout,
          message: null,
        ),
      PaymentProviderUnavailableFailure() => (
          type: t.payment.error.providerUnavailable,
          message: null,
        ),
      PaymentNetworkFailure() => (
          type: t.payment.error.networkError,
          message: null,
        ),
      PaymentInvalidConfigFailure() => (
          type: t.payment.error.invalidConfig,
          message: null,
        ),
      SubscriptionNotFoundFailure() => (
          type: t.payment.error.subscriptionNotFound,
          message: null,
        ),
      SubscriptionExpiredFailure() => (
          type: t.payment.error.subscriptionExpired,
          message: null,
        ),
    };
  }
}