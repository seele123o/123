import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hiddify/features/panel/xboard/providers/index.dart';
import 'package:hiddify/features/panel/xboard/services/payment/payment_exceptions.dart';
// lib/features/panel/xboard/services/payment/stripe_service.dart
// lib/features/panel/xboard/services/payment/revenuecat_service.dart
import 'package:purchases_flutter/purchases_flutter.dart';

class StripeService {
  static bool _isInitialized = false;

  static Future<void> initializeStripe(String customerId) async {
    if (_isInitialized) return;

    try {
      final config = await PaymentConfig.getConfig();
      
      // 初始化 Stripe SDK
      Stripe.publishableKey = config.stripePublishableKey;
      await Stripe.instance.applySettings();
      
      // 设置客户ID
      await Stripe.instance.initCustomerSession(
        setupIntentClientSecret: customerId,
      );

      _isInitialized = true;
    } catch (e) {
      throw PaymentException(
        'Failed to initialize Stripe: $e',
        code: 'stripe_init_failed',
      );
    }
  }

  static Future<void> cleanup() async {
    try {
      if (_isInitialized) {
        await Stripe.instance.resetCustomerSession();
        _isInitialized = false;
      }
    } catch (e) {
      print('Error cleaning up Stripe: $e');
    }
  }

  // 处理支付
  static Future<Map<String, dynamic>> handlePayment(
    String clientSecret,
  ) async {
    try {
      // 确保已初始化
      if (!_isInitialized) {
        throw PaymentException('Stripe not initialized');
      }

      // 显示支付页面
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      return {
        'id': paymentIntent.id,
        'status': paymentIntent.status,
        'amount': paymentIntent.amount,
        'currency': paymentIntent.currency,
      };
    } catch (e) {
      throw PaymentException(
        'Payment failed: $e',
        code: 'stripe_payment_failed',
      );
    }
  }
}

class RevenueCatService {
  static bool _isInitialized = false;

  static Future<void> initializeRevenueCat(String userId) async {
    if (_isInitialized) return;

    try {
      final config = await PaymentConfig.getConfig();
      
      // 初始化 RevenueCat SDK
      await Purchases.setLogLevel(LogLevel.debug);
      await Purchases.configure(
        PurchasesConfiguration(config.revenueCatApiKey)
          ..appUserID = userId,
      );

      _isInitialized = true;
    } catch (e) {
      throw PaymentException(
        'Failed to initialize RevenueCat: $e',
        code: 'revenuecat_init_failed',
      );
    }
  }

  static Future<void> cleanup() async {
    try {
      if (_isInitialized) {
        await Purchases.reset();
        _isInitialized = false;
      }
    } catch (e) {
      print('Error cleaning up RevenueCat: $e');
    }
  }

  // 处理购买
  static Future<Map<String, dynamic>> handlePurchase(
    String packageId,
  ) async {
    try {
      // 确保已初始化
      if (!_isInitialized) {
        throw PaymentException('RevenueCat not initialized');
      }

      // 获取可用套餐
      final offerings = await Purchases.getOfferings();
      final package = offerings.getPackage(packageId);
      
      if (package == null) {
        throw PaymentException('Package not found');
      }

      // 执行购买
      final purchaserInfo = await Purchases.purchasePackage(package);

      return {
        'customerInfo': purchaserInfo.customerInfo.originalJson,
        'entitlements': purchaserInfo.entitlements.active.keys.toList(),
        'status': 'completed',
      };
    } catch (e) {
      throw PaymentException(
        'Purchase failed: $e',
        code: 'revenuecat_purchase_failed',
      );
    }
  }
}