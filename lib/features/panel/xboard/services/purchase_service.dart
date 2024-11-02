import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/plan_model.dart';
import '../services/http_service/order_service.dart';
import '../services/http_service/payment_service.dart';
import '../services/http_service/plan_service.dart';
import 'package:hiddify/features/panel/xboard/services/subscription/subscription_service.dart';
import '../utils/storage/token_storage.dart';

part 'purchase_service.freezed.dart';
part 'purchase_service.g.dart';

@freezed
class PurchaseState with _$PurchaseState {
  const factory PurchaseState({
    @Default(false) bool isProcessing,
    String? error,
    String? orderId,
  }) = _PurchaseState;
}

@freezed
class PurchaseResult with _$PurchaseResult {
  const factory PurchaseResult({
    required bool success,
    String? orderId,
    String? error,
  }) = _PurchaseResult;
}

class PurchaseException implements Exception {
  final String message;
  final String? code;

  const PurchaseException(this.message, {this.code});

  @override
  String toString() => 'PurchaseException: $message${code != null ? ' (code: $code)' : ''}';
}

@riverpod
class PurchaseService extends _$PurchaseService {
  late final OrderService _orderService = OrderService();
  late final PaymentService _paymentService = PaymentService();
  late final PlanService _planService = PlanService();

  @override
  FutureOr<PurchaseState> build() {
    return const PurchaseState();
  }

  Future<List<Plan>> fetchPlanData() async {
    final accessToken = await getToken();
    if (accessToken == null) {
      throw const PurchaseException("No access token found.");
    }

    return await _planService.fetchPlanData(accessToken);
  }

  Future<void> addSubscription(
    BuildContext context,
    String accessToken,
    WidgetRef ref,
  ) async {
    state = const AsyncValue.loading();

    try {
      await Subscription.updateSubscription(context, ref);
      state = AsyncValue.data(state.value!.copyWith(isProcessing: false));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Map<String, dynamic>?> createOrder(
    int planId,
    String period,
    String accessToken,
  ) async {
    state = const AsyncValue.loading();

    try {
      final result = await _orderService.createOrder(accessToken, planId, period);
      state = AsyncValue.data(state.value!.copyWith(
        orderId: result?['order_id'] as String?,
        isProcessing: false,
      ));
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<List<dynamic>> getPaymentMethods(String accessToken) async {
    try {
      return await _paymentService.getPaymentMethods(accessToken);
    } catch (e) {
      throw PurchaseException('Failed to get payment methods: $e');
    }
  }

  Future<Map<String, dynamic>> submitOrder(
    String tradeNo,
    String method,
    String accessToken,
  ) async {
    state = const AsyncValue.loading();

    try {
      final result = await _paymentService.submitOrder(tradeNo, method, accessToken);
      state = AsyncValue.data(state.value!.copyWith(isProcessing: false));
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

@riverpod
class PurchaseStateNotifier extends _$PurchaseStateNotifier {
  @override
  PurchaseState build() {
    return const PurchaseState();
  }

  void startProcessing() {
    state = state.copyWith(isProcessing: true, error: null);
  }

  void setError(String error) {
    state = state.copyWith(isProcessing: false, error: error);
  }

  void setOrderId(String orderId) {
    state = state.copyWith(orderId: orderId, isProcessing: false);
  }

  void reset() {
    state = const PurchaseState();
  }
}

// 只保留一个 provider
final purchaseProgressProvider = StateNotifierProvider<PurchaseStateNotifier, PurchaseState>((ref) {
  return PurchaseStateNotifier();
});
