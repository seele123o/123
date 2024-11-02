// lib/features/panel/xboard/viewmodels/dialog_viewmodel/purchase_details_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:lib/features/panel/xboard/providers/payment_providers.dart';
import '../../models/plan_model.dart';
import '../../services/http_service/order_service.dart';
import '../../core/config/payment_config.dart';

class PurchaseDetailsViewModelParams {
  final int planId;
  final String? period;
  PurchaseDetailsViewModelParams({
    required this.planId,
    this.period,
  });
}

class PurchaseDetailsViewModel extends ChangeNotifier {
  final PurchaseDetailsViewModelParams params;
  final OrderService _orderService = OrderService();

  double? _selectedPrice;
  String? _selectedPeriod;
  bool _isProcessing = false;
  String? _error;
  String? _orderId;

  double? get selectedPrice => _selectedPrice;
  String? get selectedPeriod => _selectedPeriod;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  String? get orderId => _orderId;

  PurchaseDetailsViewModel({required this.params}) {
    if (params.period != null) {
      _selectedPeriod = params.period;
    }
  }

  void setSelectedPrice(double? price, String? period) {
    _selectedPrice = price;
    _selectedPeriod = period;
    notifyListeners();
  }

  Future<void> createOrder() async {
    if (_selectedPrice == null || _selectedPeriod == null) {
      throw Exception('No price or period selected');
    }

    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      final token = await getToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final result = await _orderService.createOrder(
        token,
        params.planId,
        _selectedPeriod!,
      );

      if (result['status'] != 'success') {
        throw Exception(result['message'] ?? 'Failed to create order');
      }

      _orderId = result['data']['order_id'];
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<List<PaymentProvider>> getAvailablePaymentMethods() async {
    if (_orderId == null) {
      throw Exception('No order created');
    }

    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final methods = await _orderService.getAvailablePaymentMethods(
        _orderId!,
        token,
      );

      // 过滤配置中启用的支付方式
      final config = await PaymentConfig.getConfig();
      return methods.where((m) =>
        config.supportedProviders.contains(m)
      ).toList();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> handlePurchase(PaymentProvider provider) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      await createOrder();

      // 根据选择的支付方式创建支付
      final token = await getToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      switch (provider) {
        case PaymentProvider.stripe:
          await _orderService.createStripePaymentIntent(
            _orderId!,
            token,
          );
          break;
        case PaymentProvider.revenuecat:
          await _orderService.createRevenueCatPurchase(
            _orderId!,
            token,
          );
          break;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }
}