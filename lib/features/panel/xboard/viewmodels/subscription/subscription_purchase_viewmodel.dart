import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:hiddify/features/panel/xboard/services/payment/revenuecat_service.dart';
import 'package:hiddify/features/panel/xboard/core/analytics/analytics_service.dart';

class SubscriptionPurchaseViewModel extends StateNotifier<AsyncValue<List<Package>>> {
  final AnalyticsService _analytics;

  SubscriptionPurchaseViewModel({
    required AnalyticsService analytics,
  })  : _analytics = analytics,
        super(const AsyncValue.loading());

  Future<void> loadPackages() async {
    try {
      state = const AsyncValue.loading();

      final packages = await RevenueCatService.getAvailablePackages();

      // 按价格排序 (月付在前，年付在后)
      packages.sort((a, b) => a.storeProduct.price.compareTo(b.storeProduct.price));

      state = AsyncValue.data(packages);

      _analytics.logEvent('subscription_packages_loaded', {
        'count': packages.length,
        'packages': packages.map((p) => p.identifier).toList(),
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _analytics.logError('load_packages_failed', e);
      rethrow;
    }
  }

  Future<void> purchasePackage(Package package) async {
    try {
      _analytics.logEvent('purchase_started', {
        'package': package.identifier,
        'price': package.storeProduct.price,
      });

      final customerInfo = await RevenueCatService.purchasePackage(package);

      _analytics.logEvent('purchase_completed', {
        'package': package.identifier,
        'user_id': customerInfo.originalAppUserId,
      });
    } catch (e) {
      _analytics.logError('purchase_failed', e);
      rethrow;
    }
  }

  Future<void> restorePurchases() async {
    try {
      _analytics.logEvent('restore_started');

      final customerInfo = await RevenueCatService.restorePurchases();

      _analytics.logEvent('restore_completed', {
        'user_id': customerInfo.originalAppUserId,
        'has_active_subscription': customerInfo.entitlements.active.isNotEmpty,
      });
    } catch (e) {
      _analytics.logError('restore_failed', e);
      rethrow;
    }
  }
}

final subscriptionPurchaseProvider = StateNotifierProvider.autoDispose<
    SubscriptionPurchaseViewModel, AsyncValue<List<Package>>>((ref) {
  final analytics = ref.watch(analyticsProvider);
  return SubscriptionPurchaseViewModel(analytics: analytics);
});
