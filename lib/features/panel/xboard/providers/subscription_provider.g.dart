// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionServiceHash() =>
    r'efd2d483a1be7769cedcddca5449b5bda64ac868';

/// See also [subscriptionService].
@ProviderFor(subscriptionService)
final subscriptionServiceProvider = Provider<SubscriptionService>.internal(
  subscriptionService,
  name: r'subscriptionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubscriptionServiceRef = ProviderRef<SubscriptionService>;
String _$subscriptionStateHash() => r'bc8d050d2b8c5010b218384c8aaf5f3dec895ee5';

/// See also [SubscriptionState].
@ProviderFor(SubscriptionState)
final subscriptionStateProvider = AutoDisposeAsyncNotifierProvider<
    SubscriptionState, SubscriptionInfo>.internal(
  SubscriptionState.new,
  name: r'subscriptionStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SubscriptionState = AutoDisposeAsyncNotifier<SubscriptionInfo>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
