// lib/features/panel/xboard/models/purchase_detail_model.dart
class PurchaseDetailPlan {
  final String name;
  final String? description;
  final Map<PlanDuration, PlanPrice> prices;
  final String? stripeProductId;
  final String? revenueCatProductId;
  final List<String>? features;
  final bool isPopular;

  PurchaseDetailPlan({
    required this.name,
    this.description,
    required this.prices,
    this.stripeProductId,
    this.revenueCatProductId,
    this.features,
    this.isPopular = false,
  });

  // 从旧结构转换
  factory PurchaseDetailPlan.fromLegacy({
    required String name,
    double? monthPrice,
    double? quarterPrice,
    double? halfYearPrice,
    double? yearPrice,
    double? twoYearPrice,
    double? threeYearPrice,
    double? onetimePrice,
  }) {
    final Map<PlanDuration, PlanPrice> prices = {};

    if (monthPrice != null) {
      prices[PlanDuration.month] = PlanPrice(
        price: monthPrice,
        duration: PlanDuration.month,
      );
    }

    if (quarterPrice != null) {
      prices[PlanDuration.quarter] = PlanPrice(
        price: quarterPrice,
        duration: PlanDuration.quarter,
      );
    }

    if (halfYearPrice != null) {
      prices[PlanDuration.halfYear] = PlanPrice(
        price: halfYearPrice,
        duration: PlanDuration.halfYear,
      );
    }

    if (yearPrice != null) {
      prices[PlanDuration.year] = PlanPrice(
        price: yearPrice,
        duration: PlanDuration.year,
      );
    }

    if (twoYearPrice != null) {
      prices[PlanDuration.twoYear] = PlanPrice(
        price: twoYearPrice,
        duration: PlanDuration.twoYear,
      );
    }

    if (threeYearPrice != null) {
      prices[PlanDuration.threeYear] = PlanPrice(
        price: threeYearPrice,
        duration: PlanDuration.threeYear,
      );
    }

    if (onetimePrice != null) {
      prices[PlanDuration.lifetime] = PlanPrice(
        price: onetimePrice,
        duration: PlanDuration.lifetime,
      );
    }

    return PurchaseDetailPlan(
      name: name,
      prices: prices,
    );
  }

  // 获取特定时长的价格
  PlanPrice? getPriceForDuration(PlanDuration duration) {
    return prices[duration];
  }

  // 获取最低月均价格
  double? get lowestMonthlyPrice {
    if (prices.isEmpty) return null;
    
    return prices.values.map((price) {
      return price.monthlyPrice;
    }).reduce((a, b) => a < b ? a : b);
  }

  // 获取原始价格（不含折扣）
  double? getOriginalPrice(PlanDuration duration) {
    return prices[duration]?.originalPrice;
  }

  // 获取折扣价格
  double? getDiscountedPrice(PlanDuration duration) {
    return prices[duration]?.price;
  }

  // 检查是否有折扣
  bool hasDiscount(PlanDuration duration) {
    final price = prices[duration];
    return price?.originalPrice != null && 
           price!.originalPrice! > price.price;
  }

  // 获取折扣百分比
  int? getDiscountPercentage(PlanDuration duration) {
    final price = prices[duration];
    if (price?.originalPrice == null) return null;
    
    return ((1 - price!.price / price.originalPrice!) * 100).round();
  }

  // 复制对象并修改部分属性
  PurchaseDetailPlan copyWith({
    String? name,
    String? description,
    Map<PlanDuration, PlanPrice>? prices,
    String? stripeProductId,
    String? revenueCatProductId,
    List<String>? features,
    bool? isPopular,
  }) {
    return PurchaseDetailPlan(
      name: name ?? this.name,
      description: description ?? this.description,
      prices: prices ?? this.prices,
      stripeProductId: stripeProductId ?? this.stripeProductId,
      revenueCatProductId: revenueCatProductId ?? this.revenueCatProductId,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
    );
  }
}

// 计划时长枚举
enum PlanDuration {
  month,
  quarter,
  halfYear,
  year,
  twoYear,
  threeYear,
  lifetime,
}

// 计划时长扩展方法
extension PlanDurationExt on PlanDuration {
  String get label {
    switch (this) {
      case PlanDuration.month:
        return '月付';
      case PlanDuration.quarter:
        return '季付';
      case PlanDuration.halfYear:
        return '半年付';
      case PlanDuration.year:
        return '年付';
      case PlanDuration.twoYear:
        return '两年付';
      case PlanDuration.threeYear:
        return '三年付';
      case PlanDuration.lifetime:
        return '终身';
    }
  }

  int get months {
    switch (this) {
      case PlanDuration.month:
        return 1;
      case PlanDuration.quarter:
        return 3;
      case PlanDuration.halfYear:
        return 6;
      case PlanDuration.year:
        return 12;
      case PlanDuration.twoYear:
        return 24;
      case PlanDuration.threeYear:
        return 36;
      case PlanDuration.lifetime:
        return -1; // 特殊值表示终身
    }
  }

  bool get isSubscription {
    return this != PlanDuration.lifetime;
  }
}

// 计划价格类
class PlanPrice {
  final double price;
  final double? originalPrice;
  final PlanDuration duration;
  final String? stripePriceId;
  final String? revenueCatOfferId;

  PlanPrice({
    required this.price,
    this.originalPrice,
    required this.duration,
    this.stripePriceId,
    this.revenueCatOfferId,
  });

  // 计算月均价格
  double get monthlyPrice {
    if (duration == PlanDuration.lifetime) {
      return price / 24; // 假设生命周期为2年来计算月均价
    }
    return price / duration.months;
  }

  // 获取节省金额
  double? get savedAmount {
    if (originalPrice == null) return null;
    return originalPrice! - price;
  }

  // 复制对象并修改部分属性
  PlanPrice copyWith({
    double? price,
    double? originalPrice,
    PlanDuration? duration,
    String? stripePriceId,
    String? revenueCatOfferId,
  }) {
    return PlanPrice(
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      duration: duration ?? this.duration,
      stripePriceId: stripePriceId ?? this.stripePriceId,
      revenueCatOfferId: revenueCatOfferId ?? this.revenueCatOfferId,
    );
  }
}
