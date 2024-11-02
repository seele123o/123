// lib/core/config/payment_config.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/xboard_cache_manager.dart';

// 集中定义 PaymentProvider
enum PaymentProvider {
  stripe,
  revenuecat,
  // 其他支付提供者
}

class PaymentConfig {
  static const String _configCacheKey = 'payment_config';
  static const Duration _configCacheDuration = Duration(hours: 12);

  // 配置模型
  static PaymentConfigModel? _cachedConfig;

  // 获取支付配置
  static Future<PaymentConfigModel> getConfig() async {
    // 先尝试使用内存缓存
    if (_cachedConfig != null) {
      return _cachedConfig!;
    }

    final cacheManager = XboardCacheManager();

    try {
      // 尝试从本地缓存获取
      final cachedConfig = await cacheManager.getCachedData<PaymentConfigModel>(
        key: _configCacheKey,
        fromJson: PaymentConfigModel.fromJson,
      );

      if (cachedConfig != null) {
        _cachedConfig = cachedConfig;
        return cachedConfig;
      }

      // 从服务器获取
      final config = await _fetchConfigFromServer();

      // 缓存配置
      await cacheManager.cacheData(
        key: _configCacheKey,
        data: config,
        duration: _configCacheDuration,
      );

      _cachedConfig = config;
      return config;
    } catch (e) {
      throw Exception('Failed to get payment config: $e');
    }
  }

  // 从服务器获取配置
  static Future<PaymentConfigModel> _fetchConfigFromServer() async {
    try {
      // 使用您现有的 HTTP 服务获取配置
      final response = await getOssConfig(); // 使用您的OSS配置获取方法

      return PaymentConfigModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch payment config: $e');
    }
  }

  // 清除缓存的配置
  static Future<void> clearConfig() async {
    _cachedConfig = null;
    final cacheManager = XboardCacheManager();
    await cacheManager.clearCache(_configCacheKey);
  }
}

// 支付配置模型
class PaymentConfigModel {
  final String stripePublishableKey;
  final String stripeTestPublishableKey;
  final String revenueCatApiKey;
  final String revenueCatTestApiKey;
  final bool isTestMode;
  final String webhookSecret;
  final Map<String, dynamic> additionalConfig;

  PaymentConfigModel({
    required this.stripePublishableKey,
    required this.stripeTestPublishableKey,
    required this.revenueCatApiKey,
    required this.revenueCatTestApiKey,
    required this.isTestMode,
    required this.webhookSecret,
    this.additionalConfig = const {},
  });

  // 获取当前环境的Stripe密钥
  String get currentStripeKey => isTestMode
      ? stripeTestPublishableKey
      : stripePublishableKey;

  // 获取当前环境的RevenueCat密钥
  String get currentRevenueCatKey => isTestMode
      ? revenueCatTestApiKey
      : revenueCatApiKey;

  // 从JSON创建实例
  factory PaymentConfigModel.fromJson(Map<String, dynamic> json) {
    return PaymentConfigModel(
      stripePublishableKey: json['stripe_publishable_key'] ?? '',
      stripeTestPublishableKey: json['stripe_test_publishable_key'] ?? '',
      revenueCatApiKey: json['revenuecat_api_key'] ?? '',
      revenueCatTestApiKey: json['revenuecat_test_api_key'] ?? '',
      isTestMode: json['is_test_mode'] ?? false,
      webhookSecret: json['webhook_secret'] ?? '',
      additionalConfig: json['additional_config'] ?? {},
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'stripe_publishable_key': stripePublishableKey,
      'stripe_test_publishable_key': stripeTestPublishableKey,
      'revenuecat_api_key': revenueCatApiKey,
      'revenuecat_test_api_key': revenueCatTestApiKey,
      'is_test_mode': isTestMode,
      'webhook_secret': webhookSecret,
      'additional_config': additionalConfig,
    };
  }

  // 判断支付提供商是否可用
  bool isProviderAvailable(PaymentProvider provider) {
    // 根据配置判断是否启用特定的支付提供商
    return additionalConfig['enabled_payment_providers']?.contains(provider.name) ?? false;
  }
}
