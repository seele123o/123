// providers/subscription_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/subscription/subscription_model.dart';
import '../services/http_service/subscription/subscription_service.dart';

part 'subscription_provider.g.dart';

@riverpod
class SubscriptionState extends _$SubscriptionState {
  @override
  FutureOr<SubscriptionInfo> build() async {
    // ... 实现逻辑
  }
}

@Riverpod(keepAlive: true)
SubscriptionService subscriptionService(SubscriptionServiceRef ref) {
  return SubscriptionService(
    httpClient: ref.watch(httpClientProvider),
  );
}