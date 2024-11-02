import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/payment_process_state.dart';
import '../core/analytics/analytics_service.dart';
import '../core/error/error_handler.dart';
import '../core/error/payment_exceptions.dart';

class PaymentProcessNotifier extends StateNotifier<PaymentProcessState> {
  final ErrorHandler _errorHandler;
  final AnalyticsService _analytics;

  PaymentProcessNotifier({
    required ErrorHandler errorHandler,
    required AnalyticsService analytics,
  })  : _errorHandler = errorHandler,
        _analytics = analytics,
        super(const PaymentProcessState());

  // 开始支付流程
  void startProcess({
    required String orderId,
    required double amount,
  }) {
    state = state.copyWith(
      currentStep: PaymentStep.creatingOrder,
      isProcessing: true,
      orderId: orderId,
      amount: amount,
      error: null,
    );

    _analytics.logEvent('payment_process_started', {
      'order_id': orderId,
      'amount': amount,
    });
  }

  // 选择支付方式
  void setPaymentMethod(String method) {
    if (!state.canProceed) return;

    state = state.copyWith(
      currentStep: PaymentStep.selectingMethod,
      selectedMethod: method,
    );

    _analytics.logEvent('payment_method_selected', {
      'method': method,
      'order_id': state.orderId,
    });
  }

  // 开始支付
  void startPayment() {
    if (!state.canProceed) return;

    state = state.copyWith(
      currentStep: PaymentStep.processingPayment,
      isProcessing: true,
      error: null,
    );

    _analytics.logEvent('payment_started', {
      'method': state.selectedMethod,
      'order_id': state.orderId,
    });
  }

  // 更新支付数据
  void setPaymentData(Map<String, dynamic> data) {
    state = state.copyWith(
      paymentData: data,
    );
  }

  // 开始验证
  void startVerification() {
    state = state.copyWith(
      currentStep: PaymentStep.verifying,
      isProcessing: true,
      progress: 0.5,
    );

    _analytics.logEvent('payment_verification_started', {
      'order_id': state.orderId,
    });
  }

  // 更新进度
  void setProgress(double progress) {
    state = state.updateProgress(progress);
  }

  // 标记完成
  void setCompleted() {
    if (state.orderId == null) {
      setError('Missing order ID');
      return;
    }

    state = PaymentProcessState.completed(
      orderId: state.orderId!,
      paymentData: state.paymentData,
    );

    _analytics.logEvent('payment_completed', {
      'order_id': state.orderId,
      'method': state.selectedMethod,
    });
  }

  // 设置错误
  void setError(String error, [Object? originalError]) {
    PaymentException? exception;
    if (originalError != null) {
      exception = _errorHandler.handlePaymentError(originalError);
      _analytics.logError(
        'payment_error',
        originalError,
        {
          'step': state.currentStep.name,
          'order_id': state.orderId,
        },
      );
    }

    state = PaymentProcessState.failed(
      error: error,
      exception: exception,
    );
  }

  // 取消支付
  void setCancelled() {
    state = PaymentProcessState.cancelled();

    _analytics.logEvent('payment_cancelled', {
      'order_id': state.orderId,
      'step': state.currentStep.name,
    });
  }

  // 重置状态
  void reset() {
    state = state.reset();
  }

  // 处理支付方式特定的结果
  void handleStripeResult(Map<String, dynamic> result) {
    if (result['error'] != null) {
      setError(result['error']['message'], result['error']);
    } else {
      setPaymentData(result);
      startVerification();
    }
  }

  void handleRevenueCatResult(Map<String, dynamic> result) {
    if (result['error'] != null) {
      setError(result['error']['message'], result['error']);
    } else {
      setPaymentData(result);
      startVerification();
    }
  }
}

// Provider
final paymentProcessProvider = StateNotifierProvider.autoDispose
    <PaymentProcessNotifier, PaymentProcessState>((ref) {
  return PaymentProcessNotifier(
    errorHandler: ref.watch(errorHandlerProvider),
    analytics: ref.watch(analyticsProvider),
  );
});