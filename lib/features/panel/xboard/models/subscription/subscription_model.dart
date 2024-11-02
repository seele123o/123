// lib/features/panel/xboard/models/subscription/subscription_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

// 需要添加部分
part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';  // 用于JSON序列化

@freezed
class SubscriptionModel with _$SubscriptionModel {
  const SubscriptionModel._();

  const factory SubscriptionModel({
    required String id,
    required bool isActive,
    required String planName,
    DateTime? expiryDate,
    String? currentPackageId,
    String? currentSubscriptionId,
    String? subscriptionStatus,
    String? paymentMethod,
    double? dataUsed,
    double? dataLimit,
    double? price,
    String? currency,
    String? billingPeriod,
    Map<String, dynamic>? features,
    String? webPageUrl,
    String? supportUrl,
    String? revenueCatUserId,
    String? revenueCatOffering,
    bool? autoRenewEnabled,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) => _$SubscriptionModelFromJson(json);

  // RevenueCat 相关
  factory SubscriptionModel.fromCustomerInfo(CustomerInfo customerInfo) {
    final active = customerInfo.entitlements.active;
    final latest = active.isNotEmpty ? active.values.first : null;

    return SubscriptionModel(
      id: customerInfo.originalAppUserId,
      isActive: active.isNotEmpty,
      planName: latest?.identifier ?? 'Unknown Plan',
      expiryDate: latest?.expirationDate,
      currentPackageId: latest?.productIdentifier,
      currentSubscriptionId: customerInfo.originalAppUserId,
      subscriptionStatus: latest?.isActive == true ? 'active' : 'inactive',
      paymentMethod: latest?.productIdentifier, // Added payment method
      dataUsed: null, // Placeholder for data used
      dataLimit: null, // Placeholder for data limit
      price: latest?.price, // Added price
      currency: latest?.currencyCode, // Added currency
      billingPeriod: latest?.billingPeriod, // Added billing period
      features: {}, // Placeholder for features
      webPageUrl: null, // Placeholder for web page URL
      supportUrl: null, // Placeholder for support URL
      revenueCatUserId: customerInfo.originalAppUserId,
      revenueCatOffering: customerInfo.originalJson['offering_identifier'],
      autoRenewEnabled: latest?.willRenew ?? false,
    );
  }

  // 便捷方法
  bool get hasActiveSubscription => isActive && (expiryDate?.isAfter(DateTime.now()) ?? false);

  double get dataUsagePercentage =>
    dataLimit != null && dataLimit! > 0 ? (dataUsed ?? 0) / dataLimit! : 0.0;

  Duration get remainingDays =>
    expiryDate?.difference(DateTime.now()) ?? Duration.zero;

  bool get isExpiringSoon =>
    hasActiveSubscription && remainingDays.inDays <= 7;
}

@freezed
class BillingHistory with _$BillingHistory {
  const factory BillingHistory({
    required String id,
    required DateTime date,
    required double amount,
    required String currency,
    required String description,
    required String status,
    String? transactionId,
    String? paymentMethod,
    bool? isRefunded,
    Map<String, dynamic>? metadata,
  }) = _BillingHistory;

  factory BillingHistory.fromJson(Map<String, dynamic> json) => _$BillingHistoryFromJson(json);
}
