// lib/features/panel/xboard/models/order_model.dart
enum OrderStatus {
  pending(0),    // 待支付
  processing(1), // 处理中
  completed(2),  // 已完成
  failed(3),     // 失败
  refunded(4),   // 已退款
  cancelled(5);  // 已取消

  final int value;
  const OrderStatus(this.value);

  static OrderStatus fromValue(int value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  bool get isActive => this == OrderStatus.completed;
  bool get isPending => this == OrderStatus.pending;
  bool get isProcessing => this == OrderStatus.processing;
}

enum PaymentProvider {
  stripe,
  revenuecat,
  other;

  String get displayName {
    switch (this) {
      case PaymentProvider.stripe:
        return 'Stripe';
      case PaymentProvider.revenuecat:
        return 'RevenueCat';
      case PaymentProvider.other:
        return '其他';
    }
  }
}

class Order {
  final int? planId;
  final String? tradeNo;
  final double? totalAmount;
  final String? period;
  final OrderStatus status;
  final int? createdAt;
  final OrderPlan? orderPlan;
  
  // 新增支付相关字段
  final PaymentProvider paymentProvider;
  final String? paymentMethodId;
  final String? paymentIntentId;
  final String? subscriptionId;
  final DateTime? expiryDate;
  final Map<String, dynamic>? metadata;
  final String? errorMessage;
  final DateTime? lastUpdated;

  Order({
    this.planId,
    this.tradeNo,
    this.totalAmount,
    this.period,
    OrderStatus? status,
    this.createdAt,
    this.orderPlan,
    this.paymentProvider = PaymentProvider.other,
    this.paymentMethodId,
    this.paymentIntentId,
    this.subscriptionId,
    this.expiryDate,
    this.metadata,
    this.errorMessage,
    this.lastUpdated,
  }) : status = status ?? OrderStatus.pending;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      planId: json['plan_id'] as int?,
      tradeNo: json['trade_no'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      period: json['period'] as String?,
      status: OrderStatus.fromValue(json['status'] as int? ?? 0),
      createdAt: json['created_at'] as int?,
      orderPlan: json['plan'] != null
          ? OrderPlan.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
      paymentProvider: _parsePaymentProvider(json['payment_provider']),
      paymentMethodId: json['payment_method_id'] as String?,
      paymentIntentId: json['payment_intent_id'] as String?,
      subscriptionId: json['subscription_id'] as String?,
      expiryDate: json['expiry_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['expiry_date'] as int)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      errorMessage: json['error_message'] as String?,
      lastUpdated: json['last_updated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_updated'] as int)
          : null,
    );
  }

  static PaymentProvider _parsePaymentProvider(String? provider) {
    switch (provider?.toLowerCase()) {
      case 'stripe':
        return PaymentProvider.stripe;
      case 'revenuecat':
        return PaymentProvider.revenuecat;
      default:
        return PaymentProvider.other;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'trade_no': tradeNo,
      'total_amount': totalAmount,
      'period': period,
      'status': status.value,
      'created_at': createdAt,
      'plan': orderPlan?.toJson(),
      'payment_provider': paymentProvider.name,
      'payment_method_id': paymentMethodId,
      'payment_intent_id': paymentIntentId,
      'subscription_id': subscriptionId,
      'expiry_date': expiryDate?.millisecondsSinceEpoch,
      'metadata': metadata,
      'error_message': errorMessage,
      'last_updated': lastUpdated?.millisecondsSinceEpoch,
    };
  }

  Order copyWith({
    int? planId,
    String? tradeNo,
    double? totalAmount,
    String? period,
    OrderStatus? status,
    int? createdAt,
    OrderPlan? orderPlan,
    PaymentProvider? paymentProvider,
    String? paymentMethodId,
    String? paymentIntentId,
    String? subscriptionId,
    DateTime? expiryDate,
    Map<String, dynamic>? metadata,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return Order(
      planId: planId ?? this.planId,
      tradeNo: tradeNo ?? this.tradeNo,
      totalAmount: totalAmount ?? this.totalAmount,
      period: period ?? this.period,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      orderPlan: orderPlan ?? this.orderPlan,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      expiryDate: expiryDate ?? this.expiryDate,
      metadata: metadata ?? this.metadata,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // 计算剩余时间
  Duration? get remainingTime {
    if (expiryDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiryDate!)) return Duration.zero;
    return expiryDate!.difference(now);
  }

  // 检查订单是否有效
  bool get isValid => status.isActive && 
      (expiryDate == null || DateTime.now().isBefore(expiryDate!));

  // 检查是否是订阅
  bool get isSubscription => period != null && period != 'onetime';

  // 获取状态显示文本
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return '待支付';
      case OrderStatus.processing:
        return '处理中';
      case OrderStatus.completed:
        return '已完成';
      case OrderStatus.failed:
        return '失败';
      case OrderStatus.refunded:
        return '已退款';
      case OrderStatus.cancelled:
        return '已取消';
    }
  }
}

class OrderPlan {
  final int id;
  final String name;
  final double? onetimePrice;
  final String? content;
  
  // 新增字段
  final String? stripeProductId;
  final String? stripePriceId;
  final String? revenueCatProductId;
  final String? revenueCatOfferId;
  final List<String>? features;
  final bool isPopular;

  OrderPlan({
    required this.id,
    required this.name,
    this.onetimePrice,
    this.content,
    this.stripeProductId,
    this.stripePriceId,
    this.revenueCatProductId,
    this.revenueCatOfferId,
    this.features,
    this.isPopular = false,
  });

  factory OrderPlan.fromJson(Map<String, dynamic> json) {
    return OrderPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      onetimePrice: (json['onetime_price'] as num?)?.toDouble(),
      content: json['content'] as String?,
      stripeProductId: json['stripe_product_id'] as String?,
      stripePriceId: json['stripe_price_id'] as String?,
      revenueCatProductId: json['revenuecat_product_id'] as String?,
      revenueCatOfferId: json['revenuecat_offer_id'] as String?,
      features: (json['features'] as List<dynamic>?)?.cast<String>(),
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'onetime_price': onetimePrice,
      'content': content,
      'stripe_product_id': stripeProductId,
      'stripe_price_id': stripePriceId,
      'revenuecat_product_id': revenueCatProductId,
      'revenuecat_offer_id': revenueCatOfferId,
      'features': features,
      'is_popular': isPopular,
    };
  }

  OrderPlan copyWith({
    int? id,
    String? name,
    double? onetimePrice,
    String? content,
    String? stripeProductId,
    String? stripePriceId,
    String? revenueCatProductId,
    String? revenueCatOfferId,
    List<String>? features,
    bool? isPopular,
  }) {
    return OrderPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      onetimePrice: onetimePrice ?? this.onetimePrice,
      content: content ?? this.content,
      stripeProductId: stripeProductId ?? this.stripeProductId,
      stripePriceId: stripePriceId ?? this.stripePriceId,
      revenueCatProductId: revenueCatProductId ?? this.revenueCatProductId,
      revenueCatOfferId: revenueCatOfferId ?? this.revenueCatOfferId,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}