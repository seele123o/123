import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/payment_process_state.dart';
import '../../models/order_model.dart';
import '../../services/payment/payment_system.dart';
import '../../services/http_service/order_service.dart';
import '../../services/http_service/payment_service.dart';
import '../../core/error/error_handler.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/config/payment_config.dart';
//import 'package:hiddify/features/panel/xboard/providers/index.dart';
import 'package:hiddify/core/localization/translations.dart';

class PaymentMethodsViewModelParams {
  final String orderId;
  final double amount;
  final VoidCallback? onPaymentSuccess;
  final Function(String)? onPaymentError;

  PaymentMethodsViewModelParams({
    required this.orderId,
    required this.amount,
    this.onPaymentSuccess,
    this.onPaymentError,
  });
}

class PaymentMethodsViewModel extends ChangeNotifier {
  final PaymentMethodsViewModelParams params;
  final PaymentService _paymentService;
  final OrderService _orderService;
  final PaymentSystem _paymentSystem;
  final ErrorHandler _errorHandler;
  final AnalyticsService _analytics;
  final NotificationService _notifications;
  final PaymentConfig _config;

  PaymentProcessState _processState = const PaymentProcessState();
  List<PaymentProvider> _availableProviders = [];
  Map<PaymentProvider, bool> _providerInitStatus = {};
  Map<PaymentProvider, String?> _providerErrors = {};
  bool _isLoadingProviders = false;

  // Getters
  PaymentProcessState get processState => _processState;
  List<PaymentProvider> get availableProviders => _availableProviders;
  bool get isLoadingProviders => _isLoadingProviders;
  bool isProviderInitialized(PaymentProvider provider) => _providerInitStatus[provider] ?? false;
  String? getProviderError(PaymentProvider provider) => _providerErrors[provider];
  double? getFeeForProvider(PaymentProvider provider) => _config.getProviderFee(provider);

  PaymentMethodsViewModel({
    required this.params,
    required PaymentService paymentService,
    required OrderService orderService,
    required PaymentSystem paymentSystem,
    required ErrorHandler errorHandler,
    required AnalyticsService analytics,
    required NotificationService notifications,
    required PaymentConfig config,
  })  : _paymentService = paymentService,
        _orderService = orderService,
        _paymentSystem = paymentSystem,
        _errorHandler = errorHandler,
        _analytics = analytics,
        _notifications = notifications,
        _config = config {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadAvailableProviders();
    await _initializePaymentProviders();
  }

  Future<void> _loadAvailableProviders() async {
    try {
      _isLoadingProviders = true;
      notifyListeners();

      final providers = await _paymentService.getAvailablePaymentMethods();
      _availableProviders = providers.where((provider) => _config.isProviderEnabled(provider)).toList();

      _analytics.logEvent('payment_providers_loaded', {
        'available_providers': _availableProviders.map((p) => p.name).toList(),
      });
    } catch (e) {
      final error = _errorHandler.handleError(e);
      _providerErrors[PaymentProvider.stripe] = error;
      _providerErrors[PaymentProvider.revenuecat] = error;

      _analytics.logError('load_providers_failed', e);
    } finally {
      _isLoadingProviders = false;
      notifyListeners();
    }
  }

  Future<void> _initializePaymentProviders() async {
    for (final provider in _availableProviders) {
      try {
        await _initializeProvider(provider);
        _providerInitStatus[provider] = true;
        _providerErrors[provider] = null;
      } catch (e) {
        _providerInitStatus[provider] = false;
        _providerErrors[provider] = _errorHandler.handleError(e);
        _analytics.logError('provider_init_failed', e, {'provider': provider.name});
      }
      notifyListeners();
    }
  }

  Future<void> _initializeProvider(PaymentProvider provider) async {
    switch (provider) {
      case PaymentProvider.stripe:
        await _paymentSystem.initializeStripe();
        break;
      case PaymentProvider.revenuecat:
        await _paymentSystem.initializeRevenueCat();
        break;
    }
  }

  Future<void> startPayment(PaymentProvider provider) async {
    if (_processState.isProcessing) return;

    try {
      // 更新状态
      _processState = _processState.copyWith(
        isProcessing: true,
        error: null,
        currentStep: PaymentStep.processingPayment,
        selectedMethod: provider.name,
      );
      notifyListeners();

      // 检查provider状态
      if (!_providerInitStatus[provider]!) {
        throw Exception('Payment provider not initialized');
      }

      // 记录分析数据
      _analytics.logEvent('payment_started', {
        'order_id': params.orderId,
        'amount': params.amount,
        'provider': provider.name,
      });

      // 处理支付
      switch (provider) {
        case PaymentProvider.stripe:
          await _handleStripePayment();
          break;
        case PaymentProvider.revenuecat:
          await _handleRevenueCatPayment();
          break;
      }
    } catch (e) {
      final error = _errorHandler.handlePaymentError(e);
      _processState = PaymentProcessState.failed(
        error: error.message,
        exception: error,
      );

      params.onPaymentError?.call(error.message);
      _notifications.show(
        title: '支付失败',
        body: error.message,
        type: NotificationType.error,
      );

      _analytics.logError('payment_failed', e, {
        'order_id': params.orderId,
        'provider': provider.name,
      });
    } finally {
      notifyListeners();
    }
  }

  Future<void> _handleStripePayment() async {
    final paymentIntent = await _orderService.createStripePaymentIntent(
      params.orderId,
    );

    _processState = _processState.copyWith(
      paymentData: paymentIntent,
      currentStep: PaymentStep.processingPayment,
    );
    notifyListeners();

    final result = await _paymentSystem.handleStripePayment(
      paymentIntent['client_secret'],
    );

    _handlePaymentResult(result);
  }

  Future<void> _handleRevenueCatPayment() async {
    final purchase = await _orderService.createRevenueCatPurchase(
      params.orderId,
    );

    _processState = _processState.copyWith(
      paymentData: purchase,
      currentStep: PaymentStep.processingPayment,
    );
    notifyListeners();

    final result = await _paymentSystem.handleRevenueCatPurchase(
      purchase['product_id'],
    );

    _handlePaymentResult(result);
  }

  void _handlePaymentResult(Map<String, dynamic> result) {
    if (result['status'] == 'success') {
      _processState = PaymentProcessState.completed(
        orderId: params.orderId,
        paymentData: result,
      );

      params.onPaymentSuccess?.call();
      _notifications.show(
        title: '支付成功',
        body: '订单支付已完成',
        type: NotificationType.success,
      );

      _analytics.logEvent('payment_completed', {
        'order_id': params.orderId,
        'provider': _processState.selectedMethod,
      });
    } else {
      throw Exception(result['error'] ?? 'Payment failed');
    }
  }

  void cancelPayment() {
    if (_processState.isProcessing) {
      _processState = PaymentProcessState.cancelled();
      notifyListeners();

      _analytics.logEvent('payment_cancelled', {
        'order_id': params.orderId,
        'step': _processState.currentStep.name,
      });
    }
  }

  void reset() {
    _processState = const PaymentProcessState();
    notifyListeners();
  }

  @override
  void dispose() {
    _paymentSystem.cleanup();
    super.dispose();
  }
}

// Provider
final paymentMethodsViewModelProvider = ChangeNotifierProvider.autoDispose.family<PaymentMethodsViewModel, PaymentMethodsViewModelParams>((ref, params) {
  return PaymentMethodsViewModel(
    params: params,
    paymentService: ref.watch(paymentServiceProvider),
    orderService: ref.watch(orderServiceProvider),
    paymentSystem: ref.watch(paymentSystemProvider),
    errorHandler: ref.watch(errorHandlerProvider),
    analytics: ref.watch(analyticsProvider),
    notifications: ref.watch(notificationServiceProvider),
    config: ref.watch(paymentConfigProvider),
  );
});
