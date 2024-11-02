// lib/features/panel/xboard/services/future_provider.dart
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/order_model.dart';
import '../services/http_service/order_service.dart';
import '../utils/storage/token_storage.dart';

// ... 保留原有的 providers ...

// 订单支付状态提供者
final orderPaymentStatusProvider = StreamProvider.family<PaymentStatus, String>((ref, orderId) async* {
  final accessToken = await getToken();
  if (accessToken == null) {
    throw Exception('No access token found');
  }

  // 检查初始状态
  final initialStatus = await OrderService().getPaymentStatus(orderId, accessToken);
  yield PaymentStatus.fromJson(initialStatus['data']);

  // 如果支付已完成或失败，不需要继续监听
 if (initialStatus['data']['status'] == 'completed' || initialStatus['data']['status'] == 'failed') {
    return;
  }

  // 定期检查支付状态
  await for (final _ in Stream.periodic(const Duration(seconds: 3))) {
    try {
      final status = await OrderService().getPaymentStatus(orderId, accessToken);
      final paymentStatus = PaymentStatus.fromJson(status['data']);
      yield paymentStatus;

      // 如果支付完成或失败，停止轮询
      if (paymentStatus.status == OrderStatus.completed || paymentStatus.status == OrderStatus.failed) {
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

// 支付方式提供者
final availablePaymentMethodsProvider = FutureProvider.family<List<PaymentProvider>, String>((ref, orderId) async {
  final accessToken = await getToken();
  if (accessToken == null) {
    throw Exception('No access token found');
  }

  return await OrderService().getAvailablePaymentMethods(orderId, accessToken);
});

// 支付配置提供者
final paymentConfigProvider = FutureProvider<PaymentConfigModel>((ref) async {
  return await PaymentConfig.getConfig();
});

// 活跃订阅提供者
final activeSubscriptionProvider = StreamProvider<SubscriptionStatus>((ref) async* {
  final userInfo = await ref.watch(userInfoProvider.future);
  if (userInfo == null) {
    throw Exception('User not found');
  }

  // 发送初始状态
  yield SubscriptionStatus(
    isActive: userInfo.hasActiveSubscription,
    subscriptionId: userInfo.currentSubscriptionId,
    expiryDate: userInfo.subscriptionEndDate != null ? DateTime.fromMillisecondsSinceEpoch(userInfo.subscriptionEndDate!) : null,
  );

  // 定期检查订阅状态
  await for (final _ in Stream.periodic(const Duration(minutes: 5))) {
    try {
      final status = await OrderService().syncSubscriptionStatus(
        await getToken() ?? '',
      );

      yield SubscriptionStatus.fromJson(status['data']);
    } catch (e) {
      // 错误时保持最后一个状态
      continue;
    }
  }
});

// 支付处理状态提供者
final paymentProcessProvider = StateNotifierProvider.family<PaymentProcessNotifier, PaymentProcessState, String>((ref, orderId) {
  return PaymentProcessNotifier(orderId: orderId, ref: ref);
});

// 支付处理状态
class PaymentProcessState {
  final bool isProcessing;
  final String? error;
  final PaymentProvider? selectedProvider;
  final Map<String, dynamic>? paymentData;

  PaymentProcessState({
    this.isProcessing = false,
    this.error,
    this.selectedProvider,
    this.paymentData,
  });

  PaymentProcessState copyWith({
    bool? isProcessing,
    String? error,
    PaymentProvider? selectedProvider,
    Map<String, dynamic>? paymentData,
  }) {
    return PaymentProcessState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
      selectedProvider: selectedProvider ?? this.selectedProvider,
      paymentData: paymentData ?? this.paymentData,
    );
  }
}

class PaymentProcessNotifier extends StateNotifier<PaymentProcessState> {
  final String orderId;
  final Ref ref;

  PaymentProcessNotifier({
    required this.orderId,
    required this.ref,
  }) : super(PaymentProcessState());

  Future<void> startPayment(PaymentProvider provider) async {
    state = state.copyWith(
      isProcessing: true,
      error: null,
      selectedProvider: provider,
    );

    try {
      final accessToken = await getToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final paymentData = await (provider == PaymentProvider.stripe ? _handleStripePayment(orderId, accessToken) : _handleRevenueCatPayment(orderId, accessToken));

      state = state.copyWith(
        paymentData: paymentData,
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> _handleStripePayment(
    String orderId,
    String accessToken,
  ) async {
    try {
      final orderService = OrderService();
      final paymentIntent = await orderService.createStripePaymentIntent(
        orderId,
        accessToken,
      );

      final paymentResult = await presentStripePayment(paymentIntent);

      if (paymentResult['status'] == 'succeeded') {
        await orderService.confirmStripePayment(
          orderId,
          paymentResult['paymentIntentId'],
          accessToken,
        );
      }

      return paymentResult;
    } catch (e) {
      throw PaymentException('Stripe payment failed: $e');
    }
  }

  Future<Map<String, dynamic>> _handleRevenueCatPayment(
    String orderId,
    String accessToken,
  ) async {
    try {
      final orderService = OrderService();
      final purchase = await orderService.createRevenueCatPurchase(
        orderId,
        accessToken,
      );

      final purchaseResult = await presentRevenueCatPurchase(purchase);

      if (purchaseResult['status'] == 'completed') {
        await orderService.confirmRevenueCatPurchase(
          orderId,
          purchaseResult['purchaseToken'],
          accessToken,
        );
      }

      return purchaseResult;
    } catch (e) {
      throw PaymentException('RevenueCat purchase failed: $e');
    }
  }

  Future<void> confirmPayment() async {
    if (!state.paymentData?['requiresConfirmation'] ?? false) {
      return;
    }

    state = state.copyWith(isProcessing: true);

    try {
      final accessToken = await getToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final orderService = OrderService();

      if (state.selectedProvider == PaymentProvider.stripe) {
        await orderService.confirmStripePayment(
          orderId,
          state.paymentData!['paymentIntentId'],
          accessToken,
        );
      } else {
        await orderService.confirmRevenueCatPurchase(
          orderId,
          state.paymentData!['purchaseToken'],
          accessToken,
        );
      }

      state = state.copyWith(
        isProcessing: false,
        paymentData: {...state.paymentData!, 'confirmed': true},
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = PaymentProcessState();
  }
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => message;
}

class SubscriptionStatus {
  final bool isActive;
  final String? subscriptionId;
  final DateTime? expiryDate;
  final String? error;

  SubscriptionStatus({
    required this.isActive,
    this.subscriptionId,
    this.expiryDate,
    this.error,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      isActive: json['is_active'] as bool? ?? false,
      subscriptionId: json['subscription_id'] as String?,
      expiryDate: json['expiry_date'] != null ? DateTime.fromMillisecondsSinceEpoch(json['expiry_date'] as int) : null,
      error: json['error'] as String?,
    );
  }
}
