// lib/features/panel/xboard/providers/index.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../viewmodels/dialog_viewmodel/payment_methods_viewmodel.dart';

// 外部服务导入
import '../core/analytics/analytics_service.dart';
import '../core/config/payment_config.dart';
import '../core/error/error_handler.dart';
import '../core/storage/xboard_cache_manager.dart';

// 模型导入
import '../models/order_model.dart';
import '../models/payment_process_state.dart';
import '../models/plan_model.dart';
import '../models/payment_failure.dart';

// HTTP 服务导入
import '../services/http_service/auth_service.dart';
import '../services/http_service/http_service.dart';
import '../services/http_service/order_service.dart';
import '../services/http_service/payment_service.dart';
import '../services/http_service/plan_service.dart';
import '../services/http_service/user_service.dart';

// 支付服务导入
import '../services/payment/payment_system.dart';
import '../services/payment/revenuecat_service.dart';
import '../services/payment/stripe_service.dart';

// 视图模型导入
import '../services/monitor_pay_status.dart';
import '../viewmodels/purchase_viewmodel.dart';
import '../viewmodels/user_info_viewmodel.dart';

// 导出必要的类型和枚举
export '../models/payment_process_state.dart' show PaymentStep;
export '../models/order_model.dart' show OrderStatus, PaymentProvider;
export '../models/plan_model.dart' show PlanSortType, PlanPeriod;
export '../models/payment_failure.dart';
export 'package:hooks_riverpod/hooks_riverpod.dart' show AsyncValue, Provider, ProviderRef;

/// 核心服务 Providers
final cacheManagerProvider = Provider<XboardCacheManager>((ref) => XboardCacheManager());
final httpServiceProvider = Provider<HttpService>((ref) => HttpService());
final errorHandlerProvider = Provider<ErrorHandler>((ref) => ErrorHandler());
final analyticsProvider = Provider<AnalyticsService>((ref) => AnalyticsService());
final configProvider = Provider<PaymentConfig>((ref) => PaymentConfig());

/// 认证相关 Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    httpService: ref.watch(httpServiceProvider),
    cacheManager: ref.watch(cacheManagerProvider),
    errorHandler: ref.watch(errorHandlerProvider),
  );
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(
    httpService: ref.watch(httpServiceProvider),
    cacheManager: ref.watch(cacheManagerProvider),
    errorHandler: ref.watch(errorHandlerProvider),
  );
});

// 支付方式 ViewModel Provider
final paymentMethodsViewModelProvider = ChangeNotifierProvider.autoDispose.family<PaymentMethodsViewModel, PaymentMethodsViewModelParams>(
  (ref, params) => PaymentMethodsViewModel(
    orderId: params.orderId,
    paymentSystem: ref.watch(paymentSystemProvider),
    orderService: ref.watch(orderServiceProvider),
    errorHandler: ref.watch(errorHandlerProvider),
  ),
);

// ----- State Providers -----

// 支付状态 Provider
final paymentStateProvider = StateNotifierProvider.autoDispose<PaymentStateNotifier, PaymentState>((ref) {
  return PaymentStateNotifier();
});

// ----- State Notifier Classes -----

// 支付状态
class PaymentState {
  final bool isProcessing;
  final String? error;
  final PaymentProvider? selectedProvider;
  final Map<String, dynamic>? paymentData;

  PaymentState({
    this.isProcessing = false,
    this.error,
    this.selectedProvider,
    this.paymentData,
  });
}

// 支付状态管理器
class PaymentStateNotifier extends StateNotifier<PaymentState> {
  PaymentStateNotifier() : super(PaymentState());

  void setProcessing(bool isProcessing) {
    state = PaymentState(
      isProcessing: isProcessing,
      error: state.error,
      selectedProvider: state.selectedProvider,
      paymentData: state.paymentData,
    );
  }

  void setError(String? error) {
    state = PaymentState(
      isProcessing: state.isProcessing,
      error: error,
      selectedProvider: state.selectedProvider,
      paymentData: state.paymentData,
    );
  }

  void setSelectedProvider(PaymentProvider provider) {
    state = PaymentState(
      isProcessing: state.isProcessing,
      error: state.error,
      selectedProvider: provider,
      paymentData: state.paymentData,
    );
  }

  void setPaymentData(Map<String, dynamic> data) {
    state = PaymentState(
      isProcessing: state.isProcessing,
      error: state.error,
      selectedProvider: state.selectedProvider,
      paymentData: data,
    );
  }

  void reset() {
    state = PaymentState();
  }
}

/// 支付相关 Providers
final stripeServiceProvider = Provider<StripeService>((ref) => StripeService());
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) => RevenueCatService());

final paymentSystemProvider = Provider<PaymentSystem>((ref) {
  return PaymentSystem(
    orderService: ref.watch(orderServiceProvider),
    stripeService: ref.watch(stripeServiceProvider),
    revenueCatService: ref.watch(revenueCatServiceProvider),
  );
});

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(
    httpService: ref.watch(httpServiceProvider),
    paymentSystem: ref.watch(paymentSystemProvider),
    errorHandler: ref.watch(errorHandlerProvider),
  );
});

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(
    httpService: ref.watch(httpServiceProvider),
    errorHandler: ref.watch(errorHandlerProvider),
  );
});

/// 计划相关 Providers
final planServiceProvider = Provider<PlanService>((ref) {
  return PlanService(
    httpService: ref.watch(httpServiceProvider),
    cacheManager: ref.watch(cacheManagerProvider),
    errorHandler: ref.watch(errorHandlerProvider),
  );
});

/// 支付监控 Provider
final monitorPayStatusProvider = Provider.autoDispose((ref) {
  return MonitorPayStatus(
    orderService: ref.watch(orderServiceProvider),
  );
});

// 从 payment_providers.dart 添加的 Providers
final paymentStateProvider = StateNotifierProvider.autoDispose<PaymentStateNotifier, PaymentState>((ref) {
  return PaymentStateNotifier();
});

final paymentProcessStateProvider = StateNotifierProvider<PaymentProcessNotifier, PaymentProcessState>((ref) {
  return PaymentProcessNotifier();
});

// 订单支付状态提供者
final orderPaymentStatusProvider = StreamProvider.family<PaymentStatus, String>((ref, orderId) async* {
  final accessToken = await getToken();
  if (accessToken == null) {
    throw Exception('No access token found');
  }

  final initialStatus = await OrderService().getPaymentStatus(orderId, accessToken);
  yield PaymentStatus.fromJson(initialStatus['data']);

  if (initialStatus['data']['status'] == 'completed' || initialStatus['data']['status'] == 'failed') {
    return;
  }

  await for (final _ in Stream.periodic(const Duration(seconds: 3))) {
    try {
      final status = await OrderService().getPaymentStatus(orderId, accessToken);
      final paymentStatus = PaymentStatus.fromJson(status['data']);
      yield paymentStatus;

      if (paymentStatus.isTerminal) {
        break;
      }
    } catch (e) {
      yield PaymentStatus(
        status: OrderStatus.failed,
        error: e.toString(),
        timestamp: DateTime.now(),
      );
      break;
    }
  }
});

/// ViewModel Providers
final purchaseViewModelProvider = ChangeNotifierProvider((ref) {
  return PurchaseViewModel(
    purchaseService: ref.watch(purchaseServiceProvider),
    paymentService: ref.watch(paymentServiceProvider),
    cacheManager: ref.watch(cacheManagerProvider),
    errorHandler: ref.watch(errorHandlerProvider),
    analytics: ref.watch(analyticsProvider),
    config: ref.watch(configProvider),
  );
});

final userInfoViewModelProvider = ChangeNotifierProvider((ref) {
  return UserInfoViewModel(
    userService: ref.watch(userServiceProvider),
    cacheManager: ref.watch(cacheManagerProvider),
    errorHandler: ref.watch(errorHandlerProvider),
    analytics: ref.watch(analyticsProvider),
  );
});

/// 状态管理 Provider
final loadingStateProvider = StateProvider<bool>((ref) => false);
final errorStateProvider = StateProvider<String?>((ref) => null);