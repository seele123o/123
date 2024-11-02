// lib/features/panel/xboard/services/payment/payment_exceptions.dart

class PaymentException implements Exception {
  final String message;
  final String code;
  final dynamic details;

  PaymentException(
    this.message, {
    required this.code,
    this.details,
  });

  @override
  String toString() {
    String detailsInfo = '';
    if (details != null) {
      detailsInfo = '\nDetails: \$details';
    }
    return 'PaymentException: \$message (code: \$code)\$detailsInfo';
  }
}

class PaymentInitializationException extends PaymentException {
  PaymentInitializationException({
    required String message,
    dynamic details,
  }) : super(message, code: 'initialization_failed', details: details);
}

class PaymentCancelledException extends PaymentException {
  PaymentCancelledException({
    String message = 'Payment cancelled by user',
    dynamic details,
  }) : super(message, code: 'payment_cancelled', details: details);
}

class PaymentNotAllowedException extends PaymentException {
  PaymentNotAllowedException({
    String message = 'Payment not allowed',
    dynamic details,
  }) : super(message, code: 'payment_not_allowed', details: details);
}

class InvalidPaymentException extends PaymentException {
  InvalidPaymentException({
    String message = 'Invalid payment',
    dynamic details,
  }) : super(message, code: 'invalid_payment', details: details);
}

class StoreProblemException extends PaymentException {
  StoreProblemException({
    String message = 'Store problem occurred',
    dynamic details,
  }) : super(message, code: 'store_problem', details: details);
}

class UnknownPaymentException extends PaymentException {
  UnknownPaymentException({
    String message = 'Unknown payment error',
    dynamic details,
  }) : super(message, code: 'unknown_error', details: details);
}
