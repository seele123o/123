import 'package:html/parser.dart' as html_parser;

class Plan {
  final int id;
  final int groupId;
  final double transferEnable;
  final String name;
  final int speedLimit;
  final bool show;
  String? content;
  final PlanPricing pricing;
  final int? createdAt;
  final int? updatedAt;
  // 新增支付相关字段
  final PlanPaymentInfo? paymentInfo;
  final List<String> features;
  final bool isPopular;
  final String? description;
  final Map<String, dynamic>? metadata;

  Plan({
    required this.id,
    required this.groupId,
    required this.transferEnable,
    required this.name,
    required this.speedLimit,
    required this.show,
    this.content,
    required this.pricing,
    this.createdAt,
    this.updatedAt,
    this.paymentInfo,
    this.features = const [],
    this.isPopular = false,
    this.description,
    this.metadata,
  });

  

  factory Plan.fromJson(Map<String, dynamic> json) {
    // 清理 HTML 标签
    final rawContent = json['content'] ?? '';
    final document = html_parser.parse(rawContent);
    final cleanContent = document.body?.text ?? '';

    return Plan(
      id: json['id'] is int ? json['id'] as int : 0,
      groupId: json['group_id'] is int ? json['group_id'] as int : 0,
      transferEnable: json['transfer_enable'] is num
          ? (json['transfer_enable'] as num).toDouble()
          : 0.0,
      name: json['name'] is String ? json['name'] as String : '未知',
      speedLimit: json['speed_limit'] is int ? json['speed_limit'] as int : 0,
      show: json['show'] == 1,
      content: cleanContent.isNotEmpty ? cleanContent : null,
      
      // 使用新的价格模型
      pricing: PlanPricing.fromJson(json),
      
      createdAt: json['created_at'] is int ? json['created_at'] as int : null,
      updatedAt: json['updated_at'] is int ? json['updated_at'] as int : null,
      
      // 新增字段解析
      paymentInfo: json['payment_info'] != null 
          ? PlanPaymentInfo.fromJson(json['payment_info']) 
          : null,
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
      isPopular: json['is_popular'] as bool? ?? false,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  // 获取特定周期的价格
  double? getPriceForPeriod(PlanPeriod period) {
    return pricing.getPriceForPeriod(period);
  }

  // 获取特定周期的支付ID
  String? getPaymentIdForPeriod(PlanPeriod period, PaymentProvider provider) {
    return paymentInfo?.getPaymentId(period, provider);
  }

  // 检查是否支持特定支付方式
  bool supportsPaymentProvider(PaymentProvider provider) {
    return paymentInfo?.supportsProvider(provider) ?? false;
  }

  // 获取月均价格
  double? getMonthlyAveragePrice(PlanPeriod period) {
    final price = getPriceForPeriod(period);
    if (price == null) return null;
    return price / period.months;
  }

  // 获取最低月均价格
  double? get lowestMonthlyPrice {
    double? lowest;
    for (var period in PlanPeriod.values) {
      final avg = getMonthlyAveragePrice(period);
      if (avg != null && (lowest == null || avg < lowest)) {
        lowest = avg;
      }
    }
    return lowest;
  }
}

// 计划价格模型
class PlanPricing {
  final double? onetimePrice;
  final double? monthPrice;
  final double? quarterPrice;
  final double? halfYearPrice;
  final double? yearPrice;
  final double? twoYearPrice;
  final double? threeYearPrice;

  PlanPricing({
    this.onetimePrice,
    this.monthPrice,
    this.quarterPrice,
    this.halfYearPrice,
    this.yearPrice,
    this.twoYearPrice,
    this.threeYearPrice,
  });

  factory PlanPricing.fromJson(Map<String, dynamic> json) {
    return PlanPricing(
      onetimePrice: json['onetime_price'] != null
          ? (json['onetime_price']! as num).toDouble() / 100
          : null,
      monthPrice: json['month_price'] != null
          ? (json['month_price']! as num).toDouble() / 100
          : null,
      quarterPrice: json['quarter_price'] != null
          ? (json['quarter_price']! as num).toDouble() / 100
          : null,
      halfYearPrice: json['half_year_price'] != null
          ? (json['half_year_price']! as num).toDouble() / 100
          : null,
      yearPrice: json['year_price'] != null
          ? (json['year_price']! as num).toDouble() / 100
          : null,
      twoYearPrice: json['two_year_price'] != null
          ? (json['two_year_price']! as num).toDouble() / 100
          : null,
      threeYearPrice: json['three_year_price'] != null
          ? (json['three_year_price']! as num).toDouble() / 100
          : null,
    );
  }

  double? getPriceForPeriod(PlanPeriod period) {
    switch (period) {
      case PlanPeriod.onetime:
        return onetimePrice;
      case PlanPeriod.month:
        return monthPrice;
      case PlanPeriod.quarter:
        return quarterPrice;
      case PlanPeriod.halfYear:
        return halfYearPrice;
      case PlanPeriod.year:
        return yearPrice;
      case PlanPeriod.twoYear:
        return twoYearPrice;
      case PlanPeriod.threeYear:
        return threeYearPrice;
    }
  }
}



// 支付相关信息模型
class PlanPaymentInfo {
  final Map<PlanPeriod, Map<PaymentProvider, String>> paymentIds;
  final List<PaymentProvider> supportedProviders;
  final Map<String, dynamic>? providerSpecificData;

  PlanPaymentInfo({
    required this.paymentIds,
    required this.supportedProviders,
    this.providerSpecificData,
  });

  factory PlanPaymentInfo.fromJson(Map<String, dynamic> json) {
    final paymentIds = <PlanPeriod, Map<PaymentProvider, String>>{};
    final supportedProviders = <PaymentProvider>[];

    // 解析支付ID
    if (json['payment_ids'] != null) {
      final periodsMap = json['payment_ids'] as Map<String, dynamic>;
      for (final periodEntry in periodsMap.entries) {
        final period = PlanPeriod.fromString(periodEntry.key);
        final providerMap = periodEntry.value as Map<String, dynamic>;
        
        paymentIds[period] = {};
        for (final providerEntry in providerMap.entries) {
          final provider = PaymentProvider.fromString(providerEntry.key);
          paymentIds[period]![provider] = providerEntry.value as String;
          
          if (!supportedProviders.contains(provider)) {
            supportedProviders.add(provider);
          }
        }
      }
    }

    return PlanPaymentInfo(
      paymentIds: paymentIds,
      supportedProviders: supportedProviders,
      providerSpecificData: json['provider_specific_data'] as Map<String, dynamic>?,
    );
  }

  String? getPaymentId(PlanPeriod period, PaymentProvider provider) {
    return paymentIds[period]?[provider];
  }

  bool supportsProvider(PaymentProvider provider) {
    return supportedProviders.contains(provider);
  }
}

// 计划周期枚举
enum PlanPeriod {
  onetime,
  month,
  quarter,
  halfYear,
  year,
  twoYear,
  threeYear;

  static PlanPeriod fromString(String str) {
    switch (str) {
      case 'onetime':
        return PlanPeriod.onetime;
      case 'month':
        return PlanPeriod.month;
      case 'quarter':
        return PlanPeriod.quarter;
      case 'half_year':
        return PlanPeriod.halfYear;
      case 'year':
        return PlanPeriod.year;
      case 'two_year':
        return PlanPeriod.twoYear;
      case 'three_year':
        return PlanPeriod.threeYear;
      default:
        throw ArgumentError('Invalid plan period: $str');
    }
  }

  enum PlanSortType {
  popular,    // 按受欢迎程度排序
  priceAsc,   // 价格升序
  priceDesc,  // 价格降序
  nameAsc,    // 名称升序
  nameDesc;   // 名称降序

  String get displayName {
    switch (this) {
      case PlanSortType.popular:
        return '推荐';
      case PlanSortType.priceAsc:
        return '价格从低到高';
      case PlanSortType.priceDesc:
        return '价格从高到低';
      case PlanSortType.nameAsc:
        return '名称 A-Z';
      case PlanSortType.nameDesc:
        return '名称 Z-A';
    }
  }

  bool get isAscending {
    return this == PlanSortType.priceAsc || this == PlanSortType.nameAsc;
  }
}
  
  String get displayName {
    switch (this) {
      case PlanPeriod.onetime:
        return '一次性';
      case PlanPeriod.month:
        return '月付';
      case PlanPeriod.quarter:
        return '季付';
      case PlanPeriod.halfYear:
        return '半年付';
      case PlanPeriod.year:
        return '年付';
      case PlanPeriod.twoYear:
        return '两年付';
      case PlanPeriod.threeYear:
        return '三年付';
    }
  }

  int get months {
    switch (this) {
      case PlanPeriod.onetime:
        return 0;
      case PlanPeriod.month:
        return 1;
      case PlanPeriod.quarter:
        return 3;
      case PlanPeriod.halfYear:
        return 6;
      case PlanPeriod.year:
        return 12;
      case PlanPeriod.twoYear:
        return 24;
      case PlanPeriod.threeYear:
        return 36;
    }
  }
}

// 支付提供商枚举
enum PaymentProvider {
  stripe,
  revenuecat;

  static PaymentProvider fromString(String str) {
    switch (str.toLowerCase()) {
      case 'stripe':
        return PaymentProvider.stripe;
      case 'revenuecat':
        return PaymentProvider.revenuecat;
      default:
        throw ArgumentError('Invalid payment provider: $str');
    }
  }

  String get displayName {
    switch (this) {
      case PaymentProvider.stripe:
        return 'Stripe';
      case PaymentProvider.revenuecat:
        return 'RevenueCat';
    }
  }
}

//需要同步修改的文件：

//plan_service.dart - 需要更新API调用以支持新的字段
//相关的ViewModel文件 - 需要处理新的支付相关功能
//UI组件 - 需要展示新的计划信息
