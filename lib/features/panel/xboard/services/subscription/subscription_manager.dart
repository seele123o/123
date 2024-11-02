import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hiddify/features/panel/xboard/models/subscription_model.dart';
import 'package:hiddify/features/panel/xboard/services/revenuecat_service.dart';
import 'package:hiddify/features/panel/xboard/core/storage/xboard_cache_manager.dart';
import 'package:hiddify/features/panel/xboard/core/analytics/analytics_service.dart';
import 'package:hiddify/features/panel/xboard/core/notifications/notification_service.dart';
import 'package:hiddify/core/localization/translations.dart';

class SubscriptionManager extends StateNotifier<AsyncValue<SubscriptionInfo>> {
  final XboardCacheManager _cacheManager;
  final AnalyticsService _analytics;
  final NotificationService _notifications;
  final Translations _translations;

  Timer? _autoRefreshTimer;
  Timer? _expiryCheckTimer;

  static const Duration _refreshInterval = Duration(minutes: 5);
  static const Duration _expiryCheckInterval = Duration(minutes: 30);
  static const Duration _cacheTimeout = Duration(hours: 1);

  SubscriptionManager({
    required XboardCacheManager cacheManager,
    required AnalyticsService analytics,
    required NotificationService notifications,
    required Translations translations,
  })  : _cacheManager = cacheManager,
        _analytics = analytics,
        _notifications = notifications,
        _translations = translations,
        super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // 尝试从缓存加载数据
    final cachedData = await _loadFromCache();
    if (cachedData != null) {
      state = AsyncValue.data(cachedData);
    }

    // 开始定时任务
    _startTimers();

    // 刷新最新数据
    await refresh();
  }

  Future<void> refresh() async {
    try {
      state = const AsyncValue.loading();

      final subscription = await RevenueCatService.checkSubscriptionStatus();

      // 缓存新数据
      await _saveToCache(subscription);

      // 更新状态
      state = AsyncValue.data(subscription);

      // 记录分析数据
      _analytics.logEvent('subscription_refreshed', {
        'is_active': subscription.isActive,
        'expiry_date': subscription.expiryDate?.toIso8601String(),
      });

      // 检查并发送通知
      _checkSubscriptionStatus(subscription);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _analytics.logError('subscription_refresh_failed', e);
    }
  }

  Future<void> restorePurchases() async {
    try {
      state = const AsyncValue.loading();

      final customerInfo = await RevenueCatService.restorePurchases();
      final subscription = SubscriptionInfo.fromCustomerInfo(customerInfo);

      await _saveToCache(subscription);
      state = AsyncValue.data(subscription);

      _analytics.logEvent('purchases_restored', {
        'success': true,
      });

      _notifications.show(
        title: _translations.purchasesRestoredTitle,
        body: _translations.purchasesRestoredBody,
        type: NotificationType.success,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _analytics.logError('restore_purchases_failed', e);

      _notifications.show(
        title: _translations.restoreFailedTitle,
        body: _translations.restoreFailedBody,
        type: NotificationType.error,
      );
    }
  }

  Future<SubscriptionInfo?> _loadFromCache() async {
    try {
      return await _cacheManager.getCachedData<SubscriptionInfo>(
        key: 'subscription_info',
        fromJson: SubscriptionInfo.fromJson,
      );
    } catch (e) {
      debugPrint('Error loading subscription from cache: $e');
      return null;
    }
  }

  Future<void> _saveToCache(SubscriptionInfo subscription) async {
    try {
      await _cacheManager.cacheData(
        key: 'subscription_info',
        data: subscription.toJson(),
        duration: _cacheTimeout,
      );
    } catch (e) {
      debugPrint('Error saving subscription to cache: $e');
    }
  }

  void _startTimers() {
    // 定期刷新订阅状态
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_refreshInterval, (_) => refresh());

    // 定期检查订阅过期状态
    _expiryCheckTimer?.cancel();
    _expiryCheckTimer = Timer.periodic(_expiryCheckInterval, (_) {
      if (state.hasValue) {
        _checkSubscriptionStatus(state.value!);
      }
    });
  }

  void _checkSubscriptionStatus(SubscriptionInfo subscription) {
    if (!subscription.isActive) {
      _notifications.show(
        title: _translations.subscriptionInactiveTitle,
        body: _translations.subscriptionInactiveBody,
        type: NotificationType.warning,
      );
      return;
    }

    if (subscription.expiryDate != null) {
      final now = DateTime.now();
      final remaining = subscription.expiryDate!.difference(now);

      if (remaining.isNegative) {
        _notifications.show(
          title: _translations.subscriptionExpiredTitle,
          body: _translations.subscriptionExpiredBody,
          type: NotificationType.alert,
        );
      } else if (remaining.inDays <= 7) {
        _notifications.show(
          title: _translations.subscriptionExpiringSoonTitle,
          body: _translations.subscriptionExpiringSoonBody(remaining.inDays),
          type: NotificationType.warning,
        );
      }
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _expiryCheckTimer?.cancel();
    super.dispose();
  }
}

// Provider
final subscriptionManagerProvider = StateNotifierProvider<SubscriptionManager, AsyncValue<SubscriptionInfo>>((ref) {
  final cacheManager = ref.watch(cacheManagerProvider);
  final analytics = ref.watch(analyticsProvider);
  final notifications = ref.watch(notificationsProvider);
  final translations = ref.watch(translationsProvider);

  return SubscriptionManager(
    cacheManager: cacheManager,
    analytics: analytics,
    notifications: notifications,
    translations: translations,
  );
});