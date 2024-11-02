// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionModelImpl _$$SubscriptionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SubscriptionModelImpl(
      id: json['id'] as String,
      isActive: json['isActive'] as bool,
      planName: json['planName'] as String,
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      currentPackageId: json['currentPackageId'] as String?,
      currentSubscriptionId: json['currentSubscriptionId'] as String?,
      subscriptionStatus: json['subscriptionStatus'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      dataUsed: (json['dataUsed'] as num?)?.toDouble(),
      dataLimit: (json['dataLimit'] as num?)?.toDouble(),
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      billingPeriod: json['billingPeriod'] as String?,
      features: json['features'] as Map<String, dynamic>?,
      webPageUrl: json['webPageUrl'] as String?,
      supportUrl: json['supportUrl'] as String?,
      revenueCatUserId: json['revenueCatUserId'] as String?,
      revenueCatOffering: json['revenueCatOffering'] as String?,
      autoRenewEnabled: json['autoRenewEnabled'] as bool?,
    );

Map<String, dynamic> _$$SubscriptionModelImplToJson(
        _$SubscriptionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isActive': instance.isActive,
      'planName': instance.planName,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'currentPackageId': instance.currentPackageId,
      'currentSubscriptionId': instance.currentSubscriptionId,
      'subscriptionStatus': instance.subscriptionStatus,
      'paymentMethod': instance.paymentMethod,
      'dataUsed': instance.dataUsed,
      'dataLimit': instance.dataLimit,
      'price': instance.price,
      'currency': instance.currency,
      'billingPeriod': instance.billingPeriod,
      'features': instance.features,
      'webPageUrl': instance.webPageUrl,
      'supportUrl': instance.supportUrl,
      'revenueCatUserId': instance.revenueCatUserId,
      'revenueCatOffering': instance.revenueCatOffering,
      'autoRenewEnabled': instance.autoRenewEnabled,
    };

_$BillingHistoryImpl _$$BillingHistoryImplFromJson(Map<String, dynamic> json) =>
    _$BillingHistoryImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      transactionId: json['transactionId'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      isRefunded: json['isRefunded'] as bool?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$BillingHistoryImplToJson(
        _$BillingHistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'currency': instance.currency,
      'description': instance.description,
      'status': instance.status,
      'transactionId': instance.transactionId,
      'paymentMethod': instance.paymentMethod,
      'isRefunded': instance.isRefunded,
      'metadata': instance.metadata,
    };
