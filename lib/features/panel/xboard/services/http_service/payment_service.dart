// lib/features/panel/xboard/services/http_service/payment_service.dart
// 第三方包导入
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 项目内导入统一从 providers/index.dart 获取
import 'package:hiddify/features/panel/xboard/providers/index.dart';

// 项目内其他必需的直接导入
import '../../utils/storage/token_storage.dart';
import '../../models/payment_failure.dart';
import '../../models/order_model.dart';

class PaymentService {
  final HttpService _httpService;
  final PaymentSystem _paymentSystem;
  final ErrorHandler _errorHandler;
  final AnalyticsService _analytics;

  PaymentService({
    required HttpService httpService,
    required PaymentSystem paymentSystem,
    required ErrorHandler errorHandler,
    required AnalyticsService analytics,
  })  : _httpService = httpService,
        _paymentSystem = paymentSystem,
        _errorHandler = errorHandler,
        _analytics = analytics;

  Future<void> processPayment(String orderId) async {
    try {
      await _paymentSystem.handlePayment(orderId);
      _analytics.logEvent('payment_success', {'order_id': orderId});
    } catch (e) {
      final error = _errorHandler.handleError(e);
      _analytics.logError('payment_failed', e);
      throw error;
    }
  }

  Future<Map<String, dynamic>> submitOrder(
    String orderId,
    PaymentProvider provider,
    String accessToken,
  ) async {
    // 验证订单状态
    final orderStatus = await _validateOrderStatus(orderId, accessToken);
    if (!orderStatus) {
      throw Exception('Invalid order status');
    }

    try {
      // 使用 PaymentSystem 处理支付
      return await _paymentSystem.handlePayment(
        orderId: orderId,
        provider: provider,
        processNotifier: PaymentProcessNotifier(),
      );
    } catch (e) {
      // 处理支付失败
      await _handlePaymentFailure(orderId, accessToken, e);
      rethrow;
    }
  }

  Future<List<PaymentProvider>> getAvailablePaymentMethods(
    String accessToken,
  ) async {
    try {
      final response = await _httpService.getRequest(
        "/api/v1/user/order/payment-methods",
        headers: {'Authorization': accessToken},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to get payment methods');
      }

      final methods = (response['data'] as List).map((method) => PaymentProvider.fromString(method)).toList();

      // 过滤掉未初始化的支付方式
      return methods.where((method) => _paymentSystem.isProviderInitialized(method)).toList();
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  Future<PaymentProcessState> getPaymentStatus(
    String orderId,
    String accessToken,
  ) async {
    try {
      final response = await _httpService.getRequest(
        "/api/v1/user/order/payment-status/$orderId",
        headers: {'Authorization': accessToken},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to get payment status');
      }

      return PaymentProcessState(
        currentStep: _parsePaymentStep(response['data']['step']),
        orderId: orderId,
        amount: response['data']['amount']?.toDouble(),
        selectedMethod: response['data']['payment_method'],
        paymentData: response['data']['payment_data'],
        error: response['data']['error'],
        progress: response['data']['progress']?.toDouble() ?? 0.0,
      );
    } catch (e) {
      throw Exception('Failed to get payment status: $e');
    }
  }

  Future<void> cancelPayment(
    String orderId,
    String accessToken,
  ) async {
    try {
      // 通知支付系统取消支付
      await _paymentSystem.cancelPayment(orderId);

      // 更新服务器订单状态
      final response = await _httpService.postRequest(
        "/api/v1/user/order/cancel",
        {"order_id": orderId},
        headers: {'Authorization': accessToken},
      );

      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'Failed to cancel payment');
      }
    } catch (e) {
      throw Exception('Failed to cancel payment: $e');
    }
  }

  // 私有辅助方法
  Future<bool> _validateOrderStatus(String orderId, String accessToken) async {
    try {
      final response = await _httpService.getRequest(
        "/api/v1/user/order/validate/$orderId",
        headers: {'Authorization': accessToken},
      );
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  Future<void> _handlePaymentFailure(
    String orderId,
    String accessToken,
    dynamic error,
  ) async {
    try {
      await _httpService.postRequest(
        "/api/v1/user/order/payment-failed",
        {
          "order_id": orderId,
          "error": error.toString(),
        },
        headers: {'Authorization': accessToken},
      );
    } catch (e) {
      // 记录错误但不抛出异常
      print('Failed to report payment failure: $e');
    }
  }

    final paymentServiceProvider = Provider<PaymentService>((ref) {
      return PaymentService(
        httpService: ref.watch(httpServiceProvider),
        paymentSystem: ref.watch(paymentSystemProvider),
        errorHandler: ref.watch(errorHandlerProvider),
        analytics: ref.watch(analyticsProvider),
      );
    });

  PaymentStep _parsePaymentStep(String step) {
    try {
      return PaymentStep.values.firstWhere(
        (s) => s.toString().split('.').last == step,
        orElse: () => PaymentStep.failed,
      );
    } catch (e) {
      return PaymentStep.failed;
    }
  }
}
