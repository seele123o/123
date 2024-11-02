import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:hiddify/features/panel/xboard/providers/index.dart';
import '../core/error/payment_exceptions.dart';
import '../models/subscription_model.dart';

class RevenueCatService {
  static bool _isInitialized = false;
  static String? _currentUserId;

  // 初始化 RevenueCat SDK
  static Future<void> initialize({
    required String apiKey,
    required String userId,
    bool observerMode = false,
  }) async {
    if (_isInitialized && userId == _currentUserId) return;

    try {
      // 配置 RevenueCat
      final configuration = PurchasesConfiguration(apiKey)
        ..appUserID = userId
        ..observerMode = observerMode;

      await Purchases.configure(configuration);
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);

      _isInitialized = true;
      _currentUserId = userId;

      // 添加状态变更监听
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _handleCustomerInfoUpdate(customerInfo);
      });
    } catch (e) {
      _isInitialized = false;
      _currentUserId = null;
      throw PaymentException(
        'Failed to initialize RevenueCat: $e',
        code: 'revenuecat_init_failed',
      );
    }
  }

  // 获取可用产品
  static Future<List<Package>> getAvailablePackages() async {
    _checkInitialization();

    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        throw PaymentException(
          'No offerings available',
          code: 'no_offerings',
        );
      }

      return offerings.current!.availablePackages;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 执行购买
  static Future<CustomerInfo> purchasePackage(Package package) async {
    _checkInitialization();

    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      return purchaseResult.customerInfo;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 恢复购买
  static Future<CustomerInfo> restorePurchases() async {
    _checkInitialization();

    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 检查订阅状态
  static Future<SubscriptionInfo> checkSubscriptionStatus() async {
    _checkInitialization();

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _mapToSubscriptionInfo(customerInfo);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 私有方法: 检查初始化状态
  static void _checkInitialization() {
    if (!_isInitialized) {
      throw PaymentException(
        'RevenueCat not initialized',
        code: 'not_initialized',
      );
    }
  }

  // 私有方法: 处理错误
  static PaymentException _handleError(dynamic error) {
    if (error is PurchasesErrorCode) {
      switch (error) {
        case PurchasesErrorCode.purchaseCancelledError:
          return PaymentException(
            'Purchase cancelled by user',
            code: 'purchase_cancelled',
          );
        case PurchasesErrorCode.storeProblemError:
          return PaymentException(
            'Store problem occurred',
            code: 'store_problem',
          );
        case PurchasesErrorCode.purchaseNotAllowedError:
          return PaymentException(
            'Purchase not allowed',
            code: 'purchase_not_allowed',
          );
        case PurchasesErrorCode.purchaseInvalidError:
          return PaymentException(
            'Invalid purchase',
            code: 'purchase_invalid',
          );
        default:
          return PaymentException(
            'RevenueCat error: $error',
            code: 'revenuecat_error',
          );
      }
    }

    return PaymentException(
      'Unknown error: $error',
      code: 'unknown_error',
    );
  }

  // 私有方法: 处理客户信息更新
  static void _handleCustomerInfoUpdate(CustomerInfo customerInfo) {
    // 可以在这里添加状态更新的处理逻辑
    debugPrint('Customer info updated: ${customerInfo.originalJson}');
  }

  // 私有方法: 映射到订阅信息模型
  static SubscriptionInfo _mapToSubscriptionInfo(CustomerInfo customerInfo) {
    final activeSubscriptions = customerInfo.entitlements.active;

    return SubscriptionInfo(
      isActive: activeSubscriptions.isNotEmpty,
      subscriptionId: customerInfo.originalAppUserId,
      expiryDate: _getLatestExpiryDate(activeSubscriptions),
      entitlements: activeSubscriptions.map((key, value) =>
        MapEntry(key, value.originalJson)).toMap(),
      revenueCatUserId: customerInfo.originalAppUserId,
      revenueCatOffering: customerInfo.originalJson['offering_identifier'],
      isRevenueCatActive: true,
    );
  }

  // 私有方法: 获取最新的过期时间
  static DateTime? _getLatestExpiryDate(Map<String, EntitlementInfo> entitlements) {
    if (entitlements.isEmpty) return null;

    return entitlements.values
      .map((e) => e.expirationDate)
      .where((date) => date != null)
      .reduce((value, element) =>
        value!.isAfter(element!) ? value : element);
  }

  // 清理资源
  static Future<void> cleanup() async {
    if (_isInitialized) {
      await Purchases.reset();
      _isInitialized = false;
      _currentUserId = null;
    }
  }
}