// lib/features/panel/xboard/constants/payment_constants.dart
abstract class PaymentConstants {
  // 默认支付限制
  static const double defaultMinAmount = 0.01;
  static const double defaultMaxAmount = 99999.99;
  static const int defaultMaxAttempts = 3;

  // 支付超时设置
  static const Duration paymentTimeout = Duration(minutes: 30);
  static const Duration paymentRetryDelay = Duration(minutes: 1);
  static const Duration statusCheckInterval = Duration(seconds: 3);

  // 缓存设置
  static const Duration configCacheDuration = Duration(hours: 12);
  static const Duration paymentMethodCacheDuration = Duration(minutes: 30);

  // Stripe 相关常量
  static const String stripeTestMode = 'test';
  static const String stripeLiveMode = 'live';
  static const Map<String, String> stripeDefaultConfig = {
    'locale': 'en',
    'appearance': {
      'theme': 'stripe',
    },
  };

  // RevenueCat 相关常量
  static const String revenueCatTestMode = 'sandbox';
  static const String revenueCatLiveMode = 'production';
  static const Map<String, String> revenueCatDefaultConfig = {
    'observerMode': 'false',
  };

  // 错误码
  static const String errorInvalidAmount = 'INVALID_AMOUNT';
  static const String errorPaymentCancelled = 'PAYMENT_CANCELLED';
  static const String errorPaymentFailed = 'PAYMENT_FAILED';
  static const String errorPaymentTimeout = 'PAYMENT_TIMEOUT';
  static const String errorProviderUnavailable = 'PROVIDER_UNAVAILABLE';
  static const String errorNetworkError = 'NETWORK_ERROR';
  static const String errorInvalidConfig = 'INVALID_CONFIG';

  // 支付状态检查
  static const int maxStatusCheckRetries = 20;
  static const Duration maxStatusCheckDuration = Duration(minutes: 5);

  // 支付方式相关
  static const Map<String, dynamic> paymentMethodDefaults = {
    'stripe': {
      'fee_rate': 2.9,
      'fixed_fee': 0.30,
      'currency': 'USD',
      'supported_payment_methods': [
        'card',
        'alipay',
        'wechat_pay',
      ],
    },
    'revenuecat': {
      'fee_rate': 15.0,
      'currency': 'USD',
      'auto_restore': true,
      'observer_mode': false,
    },
  };

  // 价格相关常量
  static const List<String> supportedCurrencies = ['CNY', 'USD', 'EUR'];
  static const String defaultCurrency = 'CNY';
  static const int defaultDecimalPlaces = 2;

  // 订单相关常量
  static const Duration orderExpiration = Duration(hours: 24);
  static const int maxOrdersPerUser = 100;
  static const Duration orderHistoryRetention = Duration(days: 90);

  // UI相关常量
  static const double paymentMethodIconSize = 32.0;
  static const double paymentFormMaxWidth = 400.0;
  static const double paymentDialogMaxHeight = 600.0;
  static const Duration paymentAnimationDuration = Duration(milliseconds: 300);
  static const List<String> supportedCardBrands = [
    'visa',
    'mastercard',
    'amex',
    'discover',
    'jcb',
    'unionpay',
  ];

  // 验证相关常量
  static RegExp get creditCardNumberPattern => RegExp(r'^\d{13,19}$');
  static RegExp get expiryDatePattern => RegExp(r'^\d\d/\d\d$');
  static RegExp get cvvPattern => RegExp(r'^\d{3,4}$');
  static RegExp get postalCodePattern => RegExp(r'^\d{4,6}$');

  // 地区相关常量
  static const List<String> supportedRegions = [
    'AS', // Asia
    'EU', // Europe
    'NA', // North America
    'SA', // South America
    'AF', // Africa
    'OC', // Oceania
  ];

  // 错误提示本地化
  static const Map<String, String> errorMessages = {
    errorInvalidAmount: 'Invalid payment amount',
    errorPaymentCancelled: 'Payment cancelled by user',
    errorPaymentFailed: 'Payment failed',
    errorPaymentTimeout: 'Payment timeout',
    errorProviderUnavailable: 'Payment method unavailable',
    errorNetworkError: 'Network error occurred',
    errorInvalidConfig: 'Invalid payment configuration',
  };

  // 日志相关常量
  static const bool enablePaymentLogs = true;
  static const Duration logRetentionPeriod = Duration(days: 30);
  static const int maxLogSize = 1024 * 1024; // 1MB

  // 测试相关常量
  static const String testCardNumber = '4242424242424242';
  static const String testExpiryDate = '12/25';
  static const String testCvv = '123';
  static const String testPostalCode = '12345';

  static const Map<String, String> testPaymentConfig = {
    'stripe_public_key': 'pk_test_your_key',
    'revenuecat_api_key': 'your_test_key',
  };

  // 安全相关常量
  static const Duration tokenExpiration = Duration(hours: 1);
  static const int maxFailedAttempts = 3;
  static const Duration lockoutDuration = Duration(minutes: 15);
}

// 支付环境枚举
enum PaymentEnvironment {
  development,
  staging,
  production;

  bool get isProduction => this == PaymentEnvironment.production;

  String get stripeMode => isProduction ? PaymentConstants.stripeLiveMode : PaymentConstants.stripeTestMode;

  String get revenueCatMode => isProduction ? PaymentConstants.revenueCatLiveMode : PaymentConstants.revenueCatTestMode;
}

// 支付错误枚举
enum PaymentErrorType {
  invalidAmount,
  paymentCancelled,
  paymentFailed,
  paymentTimeout,
  providerUnavailable,
  networkError,
  invalidConfig;

  String get code {
    switch (this) {
      case PaymentErrorType.invalidAmount:
        return PaymentConstants.errorInvalidAmount;
      case PaymentErrorType.paymentCancelled:
        return PaymentConstants.errorPaymentCancelled;
      case PaymentErrorType.paymentFailed:
        return PaymentConstants.errorPaymentFailed;
      case PaymentErrorType.paymentTimeout:
        return PaymentConstants.errorPaymentTimeout;
      case PaymentErrorType.providerUnavailable:
        return PaymentConstants.errorProviderUnavailable;
      case PaymentErrorType.networkError:
        return PaymentConstants.errorNetworkError;
      case PaymentErrorType.invalidConfig:
        return PaymentConstants.errorInvalidConfig;
    }
  }

  String get message => PaymentConstants.errorMessages[code] ?? code;
}

// 支付状态枚举
enum PaymentStatus {
  initial,
  processing,
  completed,
  failed,
  cancelled,
  refunded;

  bool get isTerminal => this == PaymentStatus.completed || this == PaymentStatus.failed || this == PaymentStatus.cancelled || this == PaymentStatus.refunded;

  bool get isSuccess => this == PaymentStatus.completed;

  bool get requiresAction => this == PaymentStatus.processing;
}
