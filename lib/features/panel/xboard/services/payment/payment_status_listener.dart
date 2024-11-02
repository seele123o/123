// lib/features/panel/xboard/services/payment/payment_status_listener.dart
import 'dart:async';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaymentStatus {
  final String status;
  final String? paymentId;
  final String? error;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  PaymentStatus({
    required this.status,
    this.paymentId,
    this.error,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class PaymentStatusListener {
  static Stream<PaymentStatus> listenToStripePayments() async* {
    // 监听 Stripe 支付状态变化
    await for (final event in Stripe.instance.onPaymentResult) {
      yield PaymentStatus(
        status: event.status.toString(),
        paymentId: event.paymentIntentId,
        details: event.toJson(),
      );
    }
  }

  static Stream<PaymentStatus> listenToRevenueCatPurchases() async* {
    // 监听 RevenueCat 购买状态变化
    final controller = StreamController<PaymentStatus>();

    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      controller.add(PaymentStatus(
        status: 'updated',
        details: customerInfo.originalJson,
      ));
    });

    yield* controller.stream;
  }

  // 合并所有支付状态流
  static Stream<PaymentStatus> listenToAllPayments() {
    return StreamGroup.merge([
      listenToStripePayments(),
      listenToRevenueCatPurchases(),
    ]);
  }
}
