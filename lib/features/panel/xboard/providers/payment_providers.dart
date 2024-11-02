// lib/features/panel/xboard/providers/payment_providers.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/payment_config_model.dart';
import '../models/payment_process_state.dart';
import '../models/order_model.dart';
import '../core/config/payment_config.dart';
import './services_provider.dart';  // 保留与其他服务提供者相关的导入

// 删除 `RevenueCatService` 的导入

/// Payment Configuration Provider
final paymentConfigProvider = FutureProvider<PaymentConfigModel>((ref) async {
  final config = await PaymentConfig.getConfig();

  // 初始化支付服务
  final paymentSystem = ref.read(paymentSystemProvider);
  await paymentSystem.initialize();

  return config;
});

/// Payment Process Providers
final paymentProcessProvider = StateNotifierProvider.autoDispose<PaymentProcessNotifier, PaymentProcessState>((ref) {
  return PaymentProcessNotifier();
});

final paymentMonitorProvider = StreamProvider.family<PaymentProcessState, String>((ref, orderId) async* {
  final paymentService = ref.watch(paymentServiceProvider);

  await for (final state in paymentService.monitorPayment(orderId)) {
    yield state;

    if (state.isCompleted || state.isFailed) {
      ref.invalidate(orderProvider(orderId));
    }
  }
});

/// Payment Methods Provider
final availablePaymentMethodsProvider = FutureProvider.family<List<PaymentProvider>, String>((ref, orderId) async {
  final config = await ref.watch(paymentConfigProvider.future);
  final paymentService = ref.watch(paymentServiceProvider);

  final methods = await paymentService.getAvailablePaymentMethods(orderId);

  // 过滤掉配置中未启用的支付方式
  return methods.where((method) => config.isProviderAvailable(method)).toList();
});

/// Order Related Providers
final orderProvider = FutureProvider.family<Order, String>((ref, orderId) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return await paymentService.getOrder(orderId);
});

/// Payment Handlers
final paymentErrorHandlerProvider = Provider((ref) {
  final paymentService = ref.watch(paymentServiceProvider);

  return (String orderId, dynamic error) async {
    // 记录错误
    await paymentService.logPaymentError(orderId, error);

    // 获取本地化的错误信息
    final errorMessage = paymentService.getLocalizedErrorMessage(error);

    // 更新支付状态
    ref.read(paymentProcessProvider.notifier).setError(errorMessage);
  };
});

final paymentSuccessHandlerProvider = Provider((ref) {
  final paymentService = ref.watch(paymentServiceProvider);

  return (String orderId) async {
    // 记录成功
    await paymentService.logPaymentSuccess(orderId);

    // 更新支付状态
    ref.read(paymentProcessProvider.notifier).setCompleted();

    // 刷新相关数据
    ref.invalidate(orderProvider(orderId));
    ref.invalidate(userSubscriptionProvider);
  };
});

/// Subscription Provider
final userSubscriptionProvider = StreamProvider((ref) {
  final paymentSystem = ref.watch(paymentSystemProvider);
  return paymentSystem.watchSubscriptionStatus();
});
