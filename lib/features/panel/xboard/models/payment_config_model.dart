// lib/features/panel/xboard/models/payment_config_model.dart
import 'package:flutter/foundation.dart';
import '../constants/payment_constants.dart';

@immutable
class PaymentConfigModel {
  final String stripePublicKey;
  final String revenueCatApiKey;
  final List<PaymentProvider> supportedProviders;
  final Map<String, dynamic> providerSettings;
  final PaymentLimits limits;
  final bool testMode;

  const PaymentConfigModel({
    required this.stripePublicKey,
    required this.revenueCatApiKey,
    required this.supportedProviders,
    required this.providerSettings,
    required this.limits,
    this.testMode = false,
  });

  factory PaymentConfigModel.fromJson(Map<String, dynamic> json) {
    return PaymentConfigModel(
      stripePublicKey: json['stripe_public_key'] as String? ?? '',
      revenueCatApiKey: json['revenuecat_api_key'] as String? ?? '',
      supportedProviders: (json['supported_providers'] as List<dynamic>?)?.map((e) => PaymentProvider.fromString(e as String)).toList() ?? [],
      providerSettings: (json['provider_settings'] as Map<String, dynamic>?) ?? {},
      limits: PaymentLimits.fromJson(
        (json['limits'] as Map<String, dynamic>?) ?? {},
      ),
      testMode: json['test_mode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stripe_public_key': stripePublicKey,
      'revenuecat_api_key': revenueCatApiKey,
      'supported_providers': supportedProviders.map((e) => e.toString()).toList(),
      'provider_settings': providerSettings,
      'limits': limits.toJson(),
      'test_mode': testMode,
    };
  }

  // 获取特定支付方式的费率
  double? getFeeRate(PaymentProvider provider) {
    return providerSettings['${provider.name}_fee_rate'] as double?;
  }

  // 检查支付方式是否可用
  bool isProviderAvailable(PaymentProvider provider) {
    return supportedProviders.contains(provider) && providerSettings['${provider.name}_enabled'] == true;
  }

  // 获取支付方式特定的配置
  Map<String, dynamic>? getProviderConfig(PaymentProvider provider) {
    return providerSettings['${provider.name}_config'] as Map<String, dynamic>?;
  }

  PaymentConfigModel copyWith({
    String? stripePublicKey,
    String? revenueCatApiKey,
    List<PaymentProvider>? supportedProviders,
    Map<String, dynamic>? providerSettings,
    PaymentLimits? limits,
    bool? testMode,
  }) {
    return PaymentConfigModel(
      stripePublicKey: stripePublicKey ?? this.stripePublicKey,
      revenueCatApiKey: revenueCatApiKey ?? this.revenueCatApiKey,
      supportedProviders: supportedProviders ?? this.supportedProviders,
      providerSettings: providerSettings ?? this.providerSettings,
      limits: limits ?? this.limits,
      testMode: testMode ?? this.testMode,
    );
  }
}

class PaymentLimits {
  final double minAmount;
  final double maxAmount;
  final int maxAttempts;
  final Duration timeout;
  final Duration retryDelay;

  const PaymentLimits({
    this.minAmount = PaymentConstants.defaultMinAmount,
    this.maxAmount = PaymentConstants.defaultMaxAmount,
    this.maxAttempts = PaymentConstants.defaultMaxAttempts,
    this.timeout = const Duration(minutes: 30),
    this.retryDelay = const Duration(minutes: 1),
  });

  factory PaymentLimits.fromJson(Map<String, dynamic> json) {
    return PaymentLimits(
      minAmount: (json['min_amount'] as num?)?.toDouble() ?? PaymentConstants.defaultMinAmount,
      maxAmount: (json['max_amount'] as num?)?.toDouble() ?? PaymentConstants.defaultMaxAmount,
      maxAttempts: json['max_attempts'] as int? ?? PaymentConstants.defaultMaxAttempts,
      timeout: Duration(
        seconds: json['timeout_seconds'] as int? ?? 1800,
      ),
      retryDelay: Duration(
        seconds: json['retry_delay_seconds'] as int? ?? 60,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_amount': minAmount,
      'max_amount': maxAmount,
      'max_attempts': maxAttempts,
      'timeout_seconds': timeout.inSeconds,
      'retry_delay_seconds': retryDelay.inSeconds,
    };
  }
}

enum PaymentProvider {
  stripe,
  revenuecat;

  static PaymentProvider fromString(String value) {
    switch (value.toLowerCase()) {
      case 'stripe':
        return PaymentProvider.stripe;
      case 'revenuecat':
        return PaymentProvider.revenuecat;
      default:
        throw ArgumentError('Invalid payment provider: $value');
    }
  }

  String get displayName {
    switch (this) {
      case PaymentProvider.stripe:
        return 'Credit Card';
      case PaymentProvider.revenuecat:
        return 'In-App Purchase';
    }
  }

  String get identifier {
    return toString().split('.').last;
  }
}
