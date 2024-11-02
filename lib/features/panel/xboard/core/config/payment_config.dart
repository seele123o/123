// lib/features/panel/xboard/core/config/payment_config.dart
import 'package:flutter/foundation.dart';
import '../storage/xboard_cache_manager.dart';

class PaymentConfig {
  static PaymentConfigModel? _config;
  
  // 缓存键
  static const String _configCacheKey = 'payment_config';
  static const Duration _configCacheDuration = Duration(hours: 12);
  
  // 支付环境
  static bool get isProduction => !kDebugMode; // 根据 Flutter 的调试模式判断

  // Stripe 配置
  static String get stripePublishableKey => isProduction 
      ? _config?.stripeProductionKey ?? ''
      : _config?.stripeTestKey ?? '';

  // RevenueCat 配置
  static String get revenueCatApiKey => isProduction
      ? _config?.revenueCatProductionKey ?? ''
      : _config?.revenueCatTestKey ?? '';

  static Map<String, String> getStripeConfig() {
    return {
      'publishableKey': stripePublishableKey,
      'merchantIdentifier': 'your_merchant_identifier', // 对于Apple Pay
      'urlScheme': 'your_url_scheme', // 对于返回应用
    };
  }

  static Map<String, String> getRevenueCatConfig() {
    return {
      'apiKey': revenueCatApiKey,
      'appUserId': _config?.userIdentifier ?? '',
    };
  }

  // 获取配置
  static Future<PaymentConfigModel> getConfig() async {
    // 先检查内存缓存
    if (_config != null) return _config!;

    final cacheManager = XboardCacheManager();
    
    try {
      // 尝试从本地缓存获取
      final cachedConfig = await cacheManager.getCachedData<PaymentConfigModel>(
        key: _configCacheKey,
        fromJson: PaymentConfigModel.fromJson,
      );

      if (cachedConfig != null) {
        _config = cachedConfig;
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

      _config = config;
      return config;
    } catch (e) {
      throw Exception('Failed to get payment config: $e');
    }
  }

  // 从服务器获取配置
  static Future<PaymentConfigModel> _fetchConfigFromServer() async {
    try {
      // TODO: 实现从服务器获取配置的逻辑
      // 这里返回默认配置作为示例
      return PaymentConfigModel(
        stripeProductionKey: 'YOUR_STRIPE_PRODUCTION_KEY',
        stripeTestKey: 'YOUR_STRIPE_TEST_KEY',
        revenueCatProductionKey: 'YOUR_REVENUECAT_PRODUCTION_KEY',
        revenueCatTestKey: 'YOUR_REVENUECAT_TEST_KEY',
        webhookSecret: 'YOUR_WEBHOOK_SECRET',
        supportedProviders: [
          PaymentProvider.stripe,
          PaymentProvider.revenuecat,
        ],
        paymentSettings: const PaymentSettings(),
      );
    } catch (e) {
      throw Exception('Failed to fetch payment config: $e');
    }
  }

  // 清除配置缓存
  static Future<void> clearConfig() async {
    _config = null;
    final cacheManager = XboardCacheManager();
    await cacheManager.clearCache(_configCacheKey);
  }
}

// 支付配置模型
class PaymentConfigModel {
  final String stripeProductionKey;
  final String stripeTestKey;
  final String revenueCatProductionKey;
  final String revenueCatTestKey;
  final String webhookSecret;
  final List<PaymentProvider> supportedProviders;
  final PaymentSettings paymentSettings;
  final Map<String, dynamic>? additionalConfig;
  final String? userIdentifier;

  PaymentConfigModel({
    required this.stripeProductionKey,
    required this.stripeTestKey,
    required this.revenueCatProductionKey,
    required this.revenueCatTestKey,
    required this.webhookSecret,
    required this.supportedProviders,
    required this.paymentSettings,
    this.additionalConfig,
    this.userIdentifier,
  });

  factory PaymentConfigModel.fromJson(Map<String, dynamic> json) {
    return PaymentConfigModel(
      stripeProductionKey: json['stripe_production_key'] ?? '',
      stripeTestKey: json['stripe_test_key'] ?? '',
      revenueCatProductionKey: json['revenuecat_production_key'] ?? '',
      revenueCatTestKey: json['revenuecat_test_key'] ?? '',
      webhookSecret: json['webhook_secret'] ?? '',
      supportedProviders: (json['supported_providers'] as List?)
          ?.map((p) => PaymentProvider.fromString(p))
          .toList() ?? [],
      paymentSettings: PaymentSettings.fromJson(
        json['payment_settings'] ?? {},
      ),
      additionalConfig: json['additional_config'],
      userIdentifier: json['user_identifier'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stripe_production_key': stripeProductionKey,
      'stripe_test_key': stripeTestKey,
      'revenuecat_production_key': revenueCatProductionKey,
      'revenuecat_test_key': revenueCatTestKey,
      'webhook_secret': webhookSecret,
      'supported_providers': supportedProviders.map((p) => p.name).toList(),
      'payment_settings': paymentSettings.toJson(),
      'additional_config': additionalConfig,
      'user_identifier': userIdentifier,
    };
  }
}

// 支付设置
class PaymentSettings {
  final int maxRetryAttempts;
  final Duration paymentTimeout;
  final bool enableAutoRetry;
  final Map<String, dynamic>? providerSpecificSettings;

  const PaymentSettings({
    this.maxRetryAttempts = 3,
    this.paymentTimeout = const Duration(minutes: 30),
    this.enableAutoRetry = true,
    this.providerSpecificSettings,
  });

  factory PaymentSettings.fromJson(Map<String, dynamic> json) {
    return PaymentSettings(
      maxRetryAttempts: json['max_retry_attempts'] ?? 3,
      paymentTimeout: Duration(
        seconds: json['payment_timeout_seconds'] ?? 1800,
      ),
      enableAutoRetry: json['enable_auto_retry'] ?? true,
      providerSpecificSettings: json['provider_specific_settings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_retry_attempts': maxRetryAttempts,
      'payment_timeout_seconds': paymentTimeout.inSeconds,
      'enable_auto_retry': enableAutoRetry,
      'provider_specific_settings': providerSpecificSettings,
    };
  }
}

// 支付提供商枚举
enum PaymentProvider {
  stripe,
  revenuecat,
  other; // 添加 other 选项以满足需求

  static PaymentProvider fromString(String str) {
    switch (str.toLowerCase()) {
      case 'stripe':
        return PaymentProvider.stripe;
      case 'revenuecat':
        return PaymentProvider.revenuecat;
      default:
        return PaymentProvider.other;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentProvider.stripe:
        return 'Stripe';
      case PaymentProvider.revenuecat:
        return 'RevenueCat';
      case PaymentProvider.other:
        return 'Other';
    }
  }
}