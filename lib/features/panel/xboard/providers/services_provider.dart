// lib/features/panel/xboard/providers/services_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../core/storage/xboard_cache_manager.dart';
import '../services/http_service/user_service.dart';
import '../services/http_service/purchase_service.dart';
import '../services/http_service/subscription_service.dart';
import '../services/http_service/order_service.dart';
import '../services/http_service/auth_service.dart';
import '../services/http_service/payment_service.dart';
import '../services/payment/stripe_service.dart';
import '../services/payment/revenuecat_service.dart';
import '../services/payment/payment_system.dart';

/// Basic Service Providers
final userServiceProvider = Provider((ref) => UserService());

final purchaseServiceProvider = Provider((ref) => PurchaseService());

final subscriptionServiceProvider = Provider((ref) => SubscriptionService());

final orderServiceProvider = Provider((ref) => OrderService());

final authServiceProvider = Provider((ref) => AuthService());

final cacheManagerProvider = Provider((ref) => XboardCacheManager());

/// Payment Related Service Providers
final paymentServiceProvider = Provider((ref) => PaymentService(
      httpService: ref.watch(httpServiceProvider),
      paymentSystem: ref.watch(paymentSystemProvider),
    ));

final stripeServiceProvider = Provider((ref) => StripeService());

final revenueCatServiceProvider = Provider((ref) => RevenueCatService());

final paymentSystemProvider = Provider((ref) => PaymentSystem(
      orderService: ref.watch(orderServiceProvider),
      stripeService: ref.watch(stripeServiceProvider),
      revenueCatService: ref.watch(revenueCatServiceProvider),
    ));

/// HTTP Service Provider
final httpServiceProvider = Provider((ref) => HttpService());

/// Error Handler Provider
final errorHandlerProvider = Provider((ref) => ErrorHandler());

/// Analytics Provider
final analyticsProvider = Provider((ref) => AnalyticsService(
      userService: ref.watch(userServiceProvider),
      paymentService: ref.watch(paymentServiceProvider),
    ));
