// lib/features/panel/xboard/viewmodels/dialog_viewmodel/purchase_details_viewmodel_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import './purchase_details_viewmodel.dart';
import '../../models/payment_process_state.dart';
import '../../models/order_model.dart';
import '../../core/config/payment_config.dart';
import '../../services/http_service/order_service.dart';
import '../../services/http_service/payment_service.dart';

// 购买详情 ViewModel Provider
final purchaseDetailsViewModelProvider = ChangeNotifierProvider.autoDispose.family<PurchaseDetailsViewModel, PurchaseDetailsViewModelParams>(
  (ref, params) => PurchaseDetailsViewModel(params: params),
);

// 服务提供者
final orderServiceProvider = Provider((ref) => OrderService());
final paymentServiceProvider = Provider((ref) => PaymentService());

// 套餐价格提供者
final planPricingProvider = Provider.family<PlanPricing?, int>((ref, planId) {
  final plan = ref.watch(planProvider(planId));
  return plan.whenData((plan) => plan?.pricing).value;
});

// 支付配置提供者
final paymentConfigProvider = FutureProvider<PaymentConfigModel>((ref) async {
  return await PaymentConfig.getConfig();
});

// 支付流程状态提供者
final paymentProcessProvider = StateNotifierProvider.autoDispose<PaymentProcessNotifier, PaymentProcessState>(
  (ref) => PaymentProcessNotifier(),
);

// 可用支付方式提供者
final availablePaymentMethodsProvider = FutureProvider.family<List<PaymentProvider>, String>((ref, orderId) async {
  final paymentService = ref.watch(paymentServiceProvider);
  final token = await getToken();
  if (token == null) throw Exception('No access token');

  try {
    final methods = await paymentService.getAvailablePaymentMethods(token);
    final config = await ref.watch(paymentConfigProvider.future);

    // 过滤出配置中启用的支付方式
    return methods.where((method) => config.supportedProviders.contains(method)).toList();
  } catch (e) {
    throw Exception('Failed to get payment methods: $e');
  }
});

// 支付状态监听提供者
final paymentStatusProvider = StreamProvider.family<PaymentProcessState, String>((ref, orderId) async* {
  final paymentService = ref.watch(paymentServiceProvider);
  final token = await getToken();
  if (token == null) throw Exception('No access token');

  while (true) {
    try {
      final status = await paymentService.getPaymentStatus(orderId, token);
      yield status;

      // 如果支付完成或失败，停止轮询
      if (status.isCompleted || status.isFailed || status.isCancelled) {
        break;
      }

      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
      yield const PaymentProcessState(
        currentStep: PaymentStep.failed,
        error: 'Failed to get payment status',
      );
      break;
    }
  }
});

// 订单操作提供者
final orderActionsProvider = Provider((ref) {
  final orderService = ref.watch(orderServiceProvider);
  final paymentProcess = ref.watch(paymentProcessProvider.notifier);

  return OrderActions(
    orderService: orderService,
    paymentProcess: paymentProcess,
  );
});

// 订单操作类
class OrderActions {
  final OrderService orderService;
  final PaymentProcessNotifier paymentProcess;

  OrderActions({
    required this.orderService,
    required this.paymentProcess,
  });

  Future<void> createOrder(int planId, String period, double amount) async {
    paymentProcess.startProcess(amount: amount);

    try {
      final token = await getToken();
      if (token == null) throw Exception('No access token');

      final result = await orderService.createOrder(token, planId, period);

      if (result['status'] == 'success') {
        paymentProcess.setOrderCreated(result['data']['order_id']);
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      paymentProcess.setError('Failed to create order: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No access token');

      await orderService.cancelOrder(orderId, token);
      paymentProcess.setCancelled();
    } catch (e) {
      paymentProcess.setError('Failed to cancel order: $e');
    }
  }

  Future<void> retryPayment(String orderId) async {
    paymentProcess.reset();
    paymentProcess.startProcess();

    try {
      final token = await getToken();
      if (token == null) throw Exception('No access token');

      final status = await orderService.getOrderStatus(orderId, token);
      paymentProcess.setOrderCreated(orderId);

      if (status == OrderStatus.completed) {
        paymentProcess.setCompleted();
      }
    } catch (e) {
      paymentProcess.setError('Failed to retry payment: $e');
    }
  }
}

// 支付配置缓存提供者
final paymentConfigCacheProvider = Provider((ref) {
  return PaymentConfigCache(
    config: ref.watch(paymentConfigProvider),
  );
});

// 支付配置缓存类
class PaymentConfigCache {
  final AsyncValue<PaymentConfigModel> config;

  PaymentConfigCache({required this.config});

  bool isProviderEnabled(PaymentProvider provider) {
    return config.whenData((config) => config.supportedProviders.contains(provider)).valueOrNull ?? false;
  }

  double? getProviderFee(PaymentProvider provider) {
    return config.whenData((config) => config.paymentSettings.providerSpecificSettings?['${provider.name}_fee_percentage']).valueOrNull;
  }
}
