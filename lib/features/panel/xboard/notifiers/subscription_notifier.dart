// lib/features/panel/xboard/notifier/subscription_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/features/panel/xboard/models/subscription/subscription_model.dart';
import 'package:hiddify/features/panel/xboard/models/payment_failure.dart';
import 'package:hiddify/features/panel/xboard/services/subscription/subscription_service.dart';
//import '../core/utils/logger.dart';
import '../core/analytics/analytics_service.dart';
import 'package:hiddify/features/panel/xboard/core/storage/xboard_cache_manager.dart';

part 'subscription_notifier.g.dart'; // 修复part声明

@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier with AppLogger {
  late final SubscriptionService _service;
  late final AnalyticsService _analytics;
  late final XboardCacheManager _cache;

  @override
  Stream<SubscriptionModel> build() {
    _service = ref.watch(subscriptionServiceProvider);
    _analytics = ref.watch(analyticsProvider);
    _cache = ref.watch(cacheManagerProvider);

    ref.onDispose(() {
      loggy.debug('disposing subscription notifier');
    });

    return _service
      .watchSubscription()
      .map((event) => event.getOrElse((l) => throw l))
      .doOnData((data) {
        _analytics.logEvent('subscription_status_changed', {
          'is_active': data.isActive,
          'plan': data.planName,
          'expiry': data.expiryDate?.toIso8601String(),
        });
      });
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      _service.getSubscription().run()
    );
  }

  Future<void> cancelSubscription() async {
    state = const AsyncLoading();
    final result = await _service.cancelSubscription().run();

    result.fold(
      (failure) {
        _analytics.logError(
          'subscription_cancel_failed',
          failure,
        );
        throw failure;
      },
      (_) {
        _analytics.logEvent('subscription_cancelled');
        refresh();
      }
    );
  }

  Future<void> renewSubscription() async {
    state = const AsyncLoading();
    final result = await _service.renewSubscription().run();

    result.fold(
      (failure) {
        _analytics.logError(
          'subscription_renewal_failed',
          failure,
        );
        throw failure;
      },
      (_) {
        _analytics.logEvent('subscription_renewed');
        refresh();
      }
    );
  }

  Future<void> updatePaymentMethod({
    required String paymentMethodId,
  }) async {
    state = const AsyncLoading();
    final result = await _service.updatePaymentMethod(
      paymentMethodId: paymentMethodId
    ).run();

    result.fold(
      (failure) {
        _analytics.logError(
          'payment_method_update_failed',
          failure,
        );
        throw failure;
      },
      (_) {
        _analytics.logEvent('payment_method_updated');
        refresh();
      }
    );
  }

  Future<void> enableAutoRenewal() async {
    state = const AsyncLoading();
    final result = await _service.enableAutoRenewal().run();

    result.fold(
      (failure) {
        _analytics.logError(
          'auto_renewal_enable_failed',
          failure,
        );
        throw failure;
      },
      (_) {
        _analytics.logEvent('auto_renewal_enabled');
        refresh();
      }
    );
  }

  Future<void> disableAutoRenewal() async {
    state = const AsyncLoading();
    final result = await _service.disableAutoRenewal().run();

    result.fold(
      (failure) {
        _analytics.logError(
          'auto_renewal_disable_failed',
          failure,
        );
        throw failure;
      },
      (_) {
        _analytics.logEvent('auto_renewal_disabled');
        refresh();
      }
    );
  }
}