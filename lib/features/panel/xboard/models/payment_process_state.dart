import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../core/error/payment_exceptions.dart';

part 'payment_process_state.freezed.dart';

/// 支付流程的各个步骤
enum PaymentStep {
  initial, // 初始状态
  creatingOrder, // 创建订单
  selectingMethod, // 选择支付方式
  processingPayment, // 处理支付
  verifying, // 验证支付状态
  completed, // 完成
  failed, // 失败
  cancelled; // 取消

  bool get isTerminal => this == completed || this == failed || this == cancelled;
  bool get canRetry => this == failed;
  bool get requiresUserAction => this == selectingMethod || this == processingPayment;
}

/// 支付处理阶段
enum PaymentProcessPhase {
  preProcess, // 预处理（订单创建等）
  payment, // 支付处理
  postProcess; // 后处理（验证等）
}

@freezed
class PaymentProcessState with _$PaymentProcessState {
  const PaymentProcessState._();

  const factory PaymentProcessState({
    @Default(PaymentStep.initial) PaymentStep currentStep,
    @Default(false) bool isProcessing,
    String? orderId,
    double? amount,
    String? selectedMethod,
    Map<String, dynamic>? paymentData,
    String? error,
    @Default(0.0) double progress,
    DateTime? lastUpdate,
    PaymentException? lastException,
  }) = _PaymentProcessState;

  // 状态检查方法
  bool get isInitial => currentStep == PaymentStep.initial;
  bool get isCreatingOrder => currentStep == PaymentStep.creatingOrder;
  bool get isSelectingMethod => currentStep == PaymentStep.selectingMethod;
  bool get isProcessingPayment => currentStep == PaymentStep.processingPayment;
  bool get isVerifying => currentStep == PaymentStep.verifying;
  bool get isCompleted => currentStep == PaymentStep.completed;
  bool get isFailed => currentStep == PaymentStep.failed;
  bool get isCancelled => currentStep == PaymentStep.cancelled;

  // 流程状态检查
  bool get canProceed => !isProcessing && error == null && !currentStep.isTerminal;
  bool get canRetry => currentStep.canRetry && !isProcessing;
  bool get canCancel => !currentStep.isTerminal && !isProcessing;
  bool get requiresUserInput => currentStep.requiresUserAction;
  bool get showProgress => isProcessing && progress > 0;

  // 获取当前阶段
  PaymentProcessPhase get currentPhase {
    return switch (currentStep) {
      PaymentStep.initial || PaymentStep.creatingOrder => PaymentProcessPhase.preProcess,
      PaymentStep.selectingMethod || PaymentStep.processingPayment => PaymentProcessPhase.payment,
      PaymentStep.verifying => PaymentProcessPhase.postProcess,
      PaymentStep.completed || PaymentStep.failed || PaymentStep.cancelled => PaymentProcessPhase.postProcess,
    };
  }

  // 获取阶段性提示文本
  String get progressText {
    return switch (currentStep) {
      PaymentStep.creatingOrder => '创建订单...',
      PaymentStep.processingPayment => '处理支付...',
      PaymentStep.verifying => '验证支付...',
      _ => '',
    };
  }

  // 获取指定步骤的错误信息
  String? getStepError(PaymentStep step) {
    return currentStep == step ? error : null;
  }

  // 更新器方法
  PaymentProcessState markProcessing({
    required bool processing,
    double? progress,
  }) {
    return copyWith(
      isProcessing: processing,
      progress: progress ?? this.progress,
      lastUpdate: DateTime.now(),
    );
  }

  PaymentProcessState updateProgress(double newProgress) {
    return copyWith(
      progress: newProgress.clamp(0.0, 1.0),
      lastUpdate: DateTime.now(),
    );
  }

  PaymentProcessState moveToStep(
    PaymentStep step, {
    Map<String, dynamic>? additionalData,
    String? error,
  }) {
    return copyWith(
      currentStep: step,
      isProcessing: false,
      error: error,
      paymentData: additionalData ?? paymentData,
      lastUpdate: DateTime.now(),
    );
  }

  PaymentProcessState setError(
    String message, {
    PaymentException? exception,
  }) {
    return copyWith(
      currentStep: PaymentStep.failed,
      isProcessing: false,
      error: message,
      lastException: exception,
      lastUpdate: DateTime.now(),
    );
  }

  PaymentProcessState reset() {
    return const PaymentProcessState();
  }

  // 工厂方法
  factory PaymentProcessState.processing({
    required PaymentStep step,
    required double progress,
  }) {
    return PaymentProcessState(
      currentStep: step,
      isProcessing: true,
      progress: progress,
      lastUpdate: DateTime.now(),
    );
  }

  factory PaymentProcessState.completed({
    required String orderId,
    Map<String, dynamic>? paymentData,
  }) {
    return PaymentProcessState(
      currentStep: PaymentStep.completed,
      isProcessing: false,
      orderId: orderId,
      paymentData: paymentData,
      progress: 1.0,
      lastUpdate: DateTime.now(),
    );
  }

  factory PaymentProcessState.failed({
    required String error,
    PaymentException? exception,
  }) {
    return PaymentProcessState(
      currentStep: PaymentStep.failed,
      isProcessing: false,
      error: error,
      lastException: exception,
      lastUpdate: DateTime.now(),
    );
  }

  factory PaymentProcessState.cancelled() {
    return PaymentProcessState(
      currentStep: PaymentStep.cancelled,
      isProcessing: false,
      lastUpdate: DateTime.now(),
    );
  }
}
