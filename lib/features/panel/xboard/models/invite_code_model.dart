class InviteCode {
  final String code;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final bool isUsed;
  final String? usedBy;
  final InviteCodeType type;
  final InviteCodeBenefit? benefit;
  final int? maxUses;
  final int usedCount;

  InviteCode({
    required this.code,
    this.createdAt,
    this.expiresAt,
    this.isUsed = false,
    this.usedBy,
    this.type = InviteCodeType.standard,
    this.benefit,
    this.maxUses,
    this.usedCount = 0,
  });

  // 从 JSON 创建 InviteCode 实例
  factory InviteCode.fromJson(Map<String, dynamic> json) {
    return InviteCode(
      code: json['code'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int)
          : null,
      expiresAt: json['expires_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['expires_at'] as int)
          : null,
      isUsed: json['is_used'] as bool? ?? false,
      usedBy: json['used_by'] as String?,
      type: InviteCodeType.fromString(json['type'] as String? ?? 'standard'),
      benefit: json['benefit'] != null 
          ? InviteCodeBenefit.fromJson(json['benefit'] as Map<String, dynamic>)
          : null,
      maxUses: json['max_uses'] as int?,
      usedCount: json['used_count'] as int? ?? 0,
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'expires_at': expiresAt?.millisecondsSinceEpoch,
      'is_used': isUsed,
      'used_by': usedBy,
      'type': type.toString(),
      'benefit': benefit?.toJson(),
      'max_uses': maxUses,
      'used_count': usedCount,
    };
  }

  // 检查邀请码是否有效
  bool get isValid {
    if (isUsed && type != InviteCodeType.multiUse) return false;
    if (maxUses != null && usedCount >= maxUses!) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  // 检查是否即将过期（7天内）
  bool get isExpiringSoon {
    if (expiresAt == null) return false;
    final daysUntilExpiry = expiresAt!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }

  // 获取剩余可用次数
  int? get remainingUses {
    if (maxUses == null) return null;
    return maxUses! - usedCount;
  }
}

// 邀请码类型
enum InviteCodeType {
  standard,    // 标准单次使用
  multiUse,    // 多次使用
  premium,     // 高级会员专属
  trial;       // 试用码

  static InviteCodeType fromString(String str) {
    switch (str.toLowerCase()) {
      case 'multi_use':
        return InviteCodeType.multiUse;
      case 'premium':
        return InviteCodeType.premium;
      case 'trial':
        return InviteCodeType.trial;
      default:
        return InviteCodeType.standard;
    }
  }

  @override
  String toString() {
    switch (this) {
      case InviteCodeType.multiUse:
        return 'multi_use';
      case InviteCodeType.premium:
        return 'premium';
      case InviteCodeType.trial:
        return 'trial';
      default:
        return 'standard';
    }
  }

  String get displayName {
    switch (this) {
      case InviteCodeType.multiUse:
        return '多次使用';
      case InviteCodeType.premium:
        return '高级会员专属';
      case InviteCodeType.trial:
        return '试用码';
      default:
        return '标准邀请码';
    }
  }
}

// 邀请码优惠内容
class InviteCodeBenefit {
  final BenefitType type;
  final double value;
  final List<int>? applicablePlans; // 适用的套餐ID列表
  final DateTime? validUntil;        // 优惠有效期

  InviteCodeBenefit({
    required this.type,
    required this.value,
    this.applicablePlans,
    this.validUntil,
  });

  factory InviteCodeBenefit.fromJson(Map<String, dynamic> json) {
    return InviteCodeBenefit(
      type: BenefitType.fromString(json['type'] as String),
      value: (json['value'] as num).toDouble(),
      applicablePlans: (json['applicable_plans'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      validUntil: json['valid_until'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['valid_until'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'value': value,
      'applicable_plans': applicablePlans,
      'valid_until': validUntil?.millisecondsSinceEpoch,
    };
  }

  // 检查优惠是否适用于特定套餐
  bool isApplicableToPlan(int planId) {
    return applicablePlans == null || applicablePlans!.contains(planId);
  }

  // 检查优惠是否有效
  bool get isValid {
    return validUntil == null || DateTime.now().isBefore(validUntil!);
  }

  // 计算优惠后的价格
  double calculateDiscountedPrice(double originalPrice) {
    switch (type) {
      case BenefitType.percentageOff:
        return originalPrice * (1 - value / 100);
      case BenefitType.fixedAmount:
        return originalPrice - value;
      case BenefitType.fixedPrice:
        return value;
    }
  }
}

// 优惠类型
enum BenefitType {
  percentageOff,  // 百分比折扣
  fixedAmount,    // 固定金额折扣
  fixedPrice;     // 固定价格

  static BenefitType fromString(String str) {
    switch (str.toLowerCase()) {
      case 'percentage_off':
        return BenefitType.percentageOff;
      case 'fixed_amount':
        return BenefitType.fixedAmount;
      case 'fixed_price':
        return BenefitType.fixedPrice;
      default:
        throw ArgumentError('Invalid benefit type: $str');
    }
  }

  @override
  String toString() {
    switch (this) {
      case BenefitType.percentageOff:
        return 'percentage_off';
      case BenefitType.fixedAmount:
        return 'fixed_amount';
      case BenefitType.fixedPrice:
        return 'fixed_price';
    }
  }

  String get displayName {
    switch (this) {
      case BenefitType.percentageOff:
        return '折扣';
      case BenefitType.fixedAmount:
        return '减免';
      case BenefitType.fixedPrice:
        return '特价';
    }
  }
}