import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // 用于本地存储

class UserInfo {
  static const String _cacheKey = 'cached_user_info';
  static const Duration _cacheDuration = Duration(hours: 24); // 缓存24小时
  
  final String email;
  final double transferEnable;
  final int? lastLoginAt;
  final int createdAt;
  final bool banned;
  final bool remindExpire;
  final bool remindTraffic;
  final int? expiredAt;
  final double balance;
  final double commissionBalance;
  final int planId;
  final double? discount;
  final double? commissionRate;
  final String? telegramId;
  final String uuid;
  final String avatarUrl;
  // 支付系统相关字段
  final String? stripeCustomerId;
  final String? revenueCatUserId;
  final bool hasActiveSubscription;
  final String? currentSubscriptionId;
  final String? subscriptionStatus;
  final int? subscriptionEndDate;
  // 新增缓存相关字段
  final int lastUpdated; // 最后更新时间戳
  final bool isCached; // 是否来自缓存

  UserInfo({
    required this.email,
    required this.transferEnable,
    this.lastLoginAt,
    required this.createdAt,
    required this.banned,
    required this.remindExpire,
    required this.remindTraffic,
    this.expiredAt,
    required this.balance,
    required this.commissionBalance,
    required this.planId,
    this.discount,
    this.commissionRate,
    this.telegramId,
    required this.uuid,
    required this.avatarUrl,
    this.stripeCustomerId,
    this.revenueCatUserId,
    this.hasActiveSubscription = false,
    this.currentSubscriptionId,
    this.subscriptionStatus,
    this.subscriptionEndDate,
    int? lastUpdated,
    this.isCached = false,
  }) : this.lastUpdated = lastUpdated ?? DateTime.now().millisecondsSinceEpoch;

  // 从 JSON 创建实例(保持原有代码)
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      // ... (保持原有字段)
      
      // 新增缓存相关字段
      lastUpdated: json['last_updated'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      isCached: json['is_cached'] as bool? ?? false,
    );
  }

  // 缓存相关方法
  static Future<void> cacheUserInfo(UserInfo userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoJson = {
      ...userInfo.toJson(),
      'last_updated': DateTime.now().millisecondsSinceEpoch,
      'is_cached': true,
    };
    await prefs.setString(_cacheKey, jsonEncode(userInfoJson));
  }

  static Future<UserInfo?> getCachedUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    
    if (cachedData != null) {
      final userInfoJson = jsonDecode(cachedData) as Map<String, dynamic>;
      final lastUpdated = userInfoJson['last_updated'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // 检查缓存是否过期
      if (now - lastUpdated <= _cacheDuration.inMilliseconds) {
        return UserInfo.fromJson(userInfoJson);
      }
    }
    return null;
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  // 检查缓存是否需要更新
  bool needsUpdate() {
    if (!isCached) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - lastUpdated > _cacheDuration.inMilliseconds;
  }

  // 智能更新方法
  static Future<UserInfo> smartFetch({
    required Future<UserInfo> Function() fetchFromServer,
  }) async {
    // 尝试从缓存获取
    final cachedInfo = await getCachedUserInfo();
    
    // 如果没有缓存或缓存需要更新,从服务器获取
    if (cachedInfo == null || cachedInfo.needsUpdate()) {
      try {
        final serverInfo = await fetchFromServer();
        await cacheUserInfo(serverInfo);
        return serverInfo;
      } catch (e) {
        // 如果服务器请求失败但有缓存,返回缓存的数据
        if (cachedInfo != null) {
          return cachedInfo;
        }
        rethrow;
      }
    }
    
    return cachedInfo;
  }

  // 订阅状态检查方法
  bool get isSubscriptionActive {
    if (!hasActiveSubscription) return false;
    if (subscriptionEndDate == null) return false;
    return DateTime.fromMillisecondsSinceEpoch(subscriptionEndDate!)
        .isAfter(DateTime.now());
  }

  // 订阅剩余时间
  Duration? get remainingSubscriptionTime {
    if (!isSubscriptionActive || subscriptionEndDate == null) return null;
    final endDate = DateTime.fromMillisecondsSinceEpoch(subscriptionEndDate!);
    return endDate.difference(DateTime.now());
  }

  // 扩展 toJson 方法
  Map<String, dynamic> toJson() {
    return {
      // ... (保持原有字段)
      'last_updated': lastUpdated,
      'is_cached': isCached,
    };
  }

  // 扩展 copyWith 方法
  UserInfo copyWith({
    // ... (保持原有参数)
    int? lastUpdated,
    bool? isCached,
  }) {
    return UserInfo(
      // ... (保持原有字段)
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isCached: isCached ?? this.isCached,
    );
  }
}

// 添加一个用户信息管理器
class UserInfoManager {
  static final UserInfoManager _instance = UserInfoManager._internal();
  factory UserInfoManager() => _instance;
  UserInfoManager._internal();

  UserInfo? _currentUserInfo;
  
  // 获取用户信息(支持缓存)
  Future<UserInfo> getUserInfo({
    required Future<UserInfo> Function() fetchFromServer,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _currentUserInfo != null) {
      return _currentUserInfo!;
    }

    _currentUserInfo = await UserInfo.smartFetch(
      fetchFromServer: fetchFromServer,
    );
    
    return _currentUserInfo!;
  }

  // 清除用户信息(登出时调用)
  Future<void> clearUserInfo() async {
    _currentUserInfo = null;
    await UserInfo.clearCache();
  }

  // 更新用户信息
  Future<void> updateUserInfo(UserInfo newInfo) async {
    _currentUserInfo = newInfo;
    await UserInfo.cacheUserInfo(newInfo);
  }
}