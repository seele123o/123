// lib/features/panel/xboard/services/payment/payment_handler.dart
import 'package:hiddify/features/panel/xboard/services/payment/stripe_service.dart';
import 'package:hiddify/features/panel/xboard/services/payment/revenuecat_service.dart';
import 'package:hiddify/features/panel/xboard/services/payment/payment_exceptions.dart';

class PaymentHandler {
  static Future<Map<String, dynamic>> handleStripePayment(
    Map<String, dynamic> paymentIntent,
  ) async {
    try {
      // 验证支付意向数据
      final clientSecret = paymentIntent['client_secret'] as String?;
      if (clientSecret == null) {
        throw PaymentException('Invalid payment intent data');
      }

      // 处理支付
      final result = await StripeService.handlePayment(clientSecret);

      // 返回处理结果
      return {
        'success': result['status'] == 'succeeded',
        'paymentIntentId': result['id'],
        'status': result['status'],
        'details': result,
      };
    } catch (e) {
      throw PaymentException('Payment failed: $e');
    }
  }

  static Future<Map<String, dynamic>> handleRevenueCatPurchase(
    Map<String, dynamic> purchaseInfo,
  ) async {
    try {
      // 验证购买信息
      final packageId = purchaseInfo['package_id'] as String?;
      if (packageId == null) {
        throw PaymentException('Invalid purchase info');
      }

      // 处理购买
      final result = await RevenueCatService.handlePurchase(packageId);

      // 返回处理结果
      return {
        'success': true,
        'status': result['status'],
        'entitlements': result['entitlements'],
        'details': result,
      };
    } catch (e) {
      throw PaymentException('Purchase failed: $e');
    }
  }
}
