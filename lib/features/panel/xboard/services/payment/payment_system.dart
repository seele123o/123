// lib/features/panel/xboard/services/payment/payment_system.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../http_service/order_service.dart';
import '../models/payment_process_state.dart';
import '../models/order_model.dart';
import '../core/config/payment_config.dart';
import 'stripe_service.dart';
import 'revenuecat_service.dart';


class PaymentSystem {
  final OrderService _orderService;
  final StripeService _stripeService;
  final RevenueCatService _revenueCatService;

  PaymentSystem({
    required OrderService orderService,
    required StripeService stripeService,
    required RevenueCatService revenueCatService,
  })  : _orderService = orderService,
        _stripeService = stripeService,
        _revenueCatService = revenueCatService;

  // 初始化支付系统
  Future<void> initialize() async {
    final config = await PaymentConfig.getConfig();

    if (config.supportedProviders.contains(PaymentProvider.stripe)) {
      await _stripeService.initialize();
    }

    if (config.supportedProviders.contains(PaymentProvider.revenuecat)) {
      await _revenueCatService.initialize();
    }
  }

  // 处理支付流程
  Future<void> handlePayment({
    required String orderId,
    required PaymentProvider provider,
    required PaymentProcessNotifier processNotifier,
  }) async {
    try {
      processNotifier.startProcess();

      switch (provider) {
        case PaymentProvider.stripe:
          await _handleStripePayment(orderId, processNotifier);
          break;
        case PaymentProvider.revenuecat:
          await _handleRevenueCatPayment(orderId, processNotifier);
          break;
      }
    } catch (e) {
      processNotifier.setError(e.toString());
      rethrow;
    }
  }

  // 处理Stripe支付
  Future<void> _handleStripePayment(
    String orderId,
    PaymentProcessNotifier processNotifier,
  ) async {
    final paymentIntent = await _orderService.createStripePaymentIntent(
      orderId,
      await getToken() ?? '',
    );

    if (paymentIntent['status'] != 'success') {
      throw Exception(paymentIntent['message'] ?? 'Failed to create payment intent');
    }

    processNotifier.setPaymentData(paymentIntent['data']);
    final result = await _stripeService.handlePayment(paymentIntent['data']);

    if (result['status'] == 'succeeded') {
      processNotifier.setCompleted();
    } else {
      throw Exception('Payment failed');
    }
  }

  // 处理RevenueCat支付
  Future<void> _handleRevenueCatPayment(
    String orderId,
    PaymentProcessNotifier processNotifier,
  ) async {
    final purchase = await _orderService.createRevenueCatPurchase(
      orderId,
      await getToken() ?? '',
    );

    if (purchase['status'] != 'success') {
      throw Exception(purchase['message'] ?? 'Failed to create purchase');
    }

    processNotifier.setPaymentData(purchase['data']);
    final result = await _revenueCatService.handlePurchase(purchase['data']);

    if (result['status'] == 'completed') {
      processNotifier.setCompleted();
    } else {
      throw Exception('Purchase failed');
    }
  }

  // 清理支付系统
  Future<void> cleanup() async {
    await Future.wait([
      _stripeService.cleanup(),
      _revenueCatService.cleanup(),
    ]);
  }
}

// Provider
final paymentSystemProvider = Provider((ref) {
  return PaymentSystem(
    orderService: OrderService(),
    stripeService: StripeService(),
    revenueCatService: RevenueCatService(),
  );
});