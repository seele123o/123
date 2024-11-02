import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaymentHandler {
  // Stripe支付处理
  Future<void> handleStripePayment({
    required String priceId,
    required String customerId,
  }) async {
    try {
      // 创建支付Intent
      final paymentIntent = await _createPaymentIntent(priceId, customerId);
      
      // 确认支付
      await Stripe.instance.confirmPayment(
        paymentIntent['client_secret'],
        PaymentMethodParams.card(),
      );
      
    } catch (e) {
      rethrow;
    }
  }

  // RevenueCat支付处理
  Future<void> handleRevenueCatPurchase({
    required String productId,
  }) async {
    try {
      // 获取可用产品
      final offerings = await Purchases.getOfferings();
      
      if (offerings.current != null) {
        // 查找匹配的产品
        final package = offerings.current!.availablePackages.firstWhere(
          (package) => package.identifier == productId,
          orElse: () => throw Exception('Product not found'),
        );
        
        // 执行购买
        await Purchases.purchasePackage(package);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // 恢复购买
  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      rethrow;
    }
  }
  
  // 检查订阅状态
  Future<bool> checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}