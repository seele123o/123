import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/payment_config.dart';

class PaymentServiceInitializer {
  static Future<void> initialize() async {
    // 初始化 Stripe
    Stripe.publishableKey = PaymentConfig.currentStripeKey;
    await Stripe.instance.applySettings();

    // 初始化 RevenueCat
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(
      PurchasesConfiguration(PaymentConfig.currentRevenueCatKey)
        ..appUserID = null  // 让 RevenueCat 管理用户 ID
        ..observerMode = false  // 设置为 true 将禁用实际购买
    );
  }
  
  // 设置用户标识
  static Future<void> identifyUser(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      print('Error identifying user: $e');
    }
  }
  
  // 清理支付状态
  static Future<void> cleanup() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      print('Error cleaning up payment services: $e');
    }
  }
}