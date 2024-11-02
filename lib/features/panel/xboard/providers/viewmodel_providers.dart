// lib/features/panel/xboard/providers/viewmodel_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../viewmodels/purchase_viewmodel.dart';
import '../viewmodels/user_info_viewmodel.dart';
import '../viewmodels/reset_subscription_viewmodel.dart';
import '../viewmodels/dialog_viewmodel/payment_methods_viewmodel.dart';
import '../viewmodels/dialog_viewmodel/purchase_details_viewmodel.dart';
import './services_provider.dart';

/// Main ViewModels
final purchaseViewModelProvider = ChangeNotifierProvider((ref) => PurchaseViewModel(
      purchaseService: ref.watch(purchaseServiceProvider),
      cacheManager: ref.watch(cacheManagerProvider),
      errorHandler: ref.watch(errorHandlerProvider),
      analytics: ref.watch(analyticsProvider),
    ));

final userInfoViewModelProvider = ChangeNotifierProvider((ref) => UserInfoViewModel(
      userService: ref.watch(userServiceProvider),
      cacheManager: ref.watch(cacheManagerProvider),
      errorHandler: ref.watch(errorHandlerProvider),
    ));

final resetSubscriptionViewModelProvider = ChangeNotifierProvider((ref) => ResetSubscriptionViewModel(
      subscriptionService: ref.watch(subscriptionServiceProvider),
      errorHandler: ref.watch(errorHandlerProvider),
    ));

/// Dialog ViewModels
final paymentMethodsViewModelProvider = ChangeNotifierProvider.autoDispose.family<PaymentMethodsViewModel, PaymentMethodsViewModelParams>(
  (ref, params) => PaymentMethodsViewModel(
    params: params,
    paymentService: ref.watch(paymentServiceProvider),
    errorHandler: ref.watch(errorHandlerProvider),
  ),
);

final purchaseDetailsViewModelProvider = ChangeNotifierProvider.autoDispose.family<PurchaseDetailsViewModel, PurchaseDetailsViewModelParams>(
  (ref, params) => PurchaseDetailsViewModel(
    params: params,
    purchaseService: ref.watch(purchaseServiceProvider),
    errorHandler: ref.watch(errorHandlerProvider),
  ),
);

/// State Management Providers
final isLoadingProvider = Provider((ref) {
  final purchaseVM = ref.watch(purchaseViewModelProvider);
  final userInfoVM = ref.watch(userInfoViewModelProvider);
  return purchaseVM.isLoading || userInfoVM.isLoading;
});
