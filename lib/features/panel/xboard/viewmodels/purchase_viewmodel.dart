// lib/features/panel/xboard/viewmodels/purchase_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/plan_model.dart';
import '../services/purchase_service.dart';
import '../core/storage/xboard_cache_manager.dart';
// lib/features/panel/xboard/viewmodels/dialog_viewmodel/payment_methods_viewmodel.dart
import 'package:flutter/foundation.dart';
//import '../../models/payment_process_state.dart';
//import '../../services/payment/payment_system.dart';
//import '../../services/http_service/order_service.dart';
import 'package:hiddify/features/panel/xboard/providers/index.dart';

class PurchaseViewModel extends ChangeNotifier {
  final PurchaseService _purchaseService;
  final XboardCacheManager _cacheManager;
  final ErrorHandler _errorHandler;
  final AnalyticsService _analytics;

  // 基础状态
  List<Plan> _plans = [];
  List<Plan> _filteredPlans = [];
  String? _errorMessage;
  bool _isLoading = false;
  bool _isRefreshing = false;

  // 搜索和排序状态
  String _searchQuery = '';
  PlanSortType _sortType = PlanSortType.popular;
  bool _isSearchMode = false;

  // Getters
  List<Plan> get plans => _filteredPlans;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasPlans => _plans.isNotEmpty;
  bool get isSearchMode => _isSearchMode;
  String get searchQuery => _searchQuery;
  PlanSortType get sortType => _sortType;

  PurchaseViewModel({
    required PurchaseService purchaseService,
    required XboardCacheManager cacheManager,
    required ErrorHandler errorHandler,
    required AnalyticsService analytics,
  })  : _purchaseService = purchaseService,
        _cacheManager = cacheManager,
        _errorHandler = errorHandler,
        _analytics = analytics {
    fetchPlans();
  }

  Future<void> fetchPlans({bool showLoadingIndicator = true}) async {
    if (_isLoading) return;

    if (showLoadingIndicator) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _plans = await _purchaseService.fetchPlanData();
      _errorMessage = null;
      _filterAndSortPlans();
      _analytics.logEvent('plans_fetched', {'count': _plans.length});
    } catch (e) {
      _errorMessage = _errorHandler.handleError(e);
      _analytics.logError('plans_fetch_error', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterAndSortPlans();
    notifyListeners();
  }

  void setSortType(PlanSortType type) {
    _sortType = type;
    _filterAndSortPlans();
    notifyListeners();
  }

  void _filterAndSortPlans() {
    _filteredPlans = _plans.where((plan) {
      if (_searchQuery.isEmpty) return true;
      final searchLower = _searchQuery.toLowerCase();
      return plan.name.toLowerCase().contains(searchLower) || 
             (plan.description?.toLowerCase().contains(searchLower) ?? false);
    }).toList();

    switch (_sortType) {
      case PlanSortType.popular:
        _filteredPlans.sort((a, b) => b.isPopular ? 1 : -1);
        break;
      case PlanSortType.priceAsc:
        _filteredPlans.sort((a, b) => 
          (a.lowestMonthlyPrice ?? double.infinity)
            .compareTo(b.lowestMonthlyPrice ?? double.infinity));
        break;
      case PlanSortType.priceDesc:
        _filteredPlans.sort((a, b) => 
          (b.lowestMonthlyPrice ?? double.infinity)
            .compareTo(a.lowestMonthlyPrice ?? double.infinity));
        break;
      case PlanSortType.nameAsc:
        _filteredPlans.sort((a, b) => a.name.compareTo(b.name));
        break;
      case PlanSortType.nameDesc:
        _filteredPlans.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
  }

  // 获取推荐计划
  Plan? getRecommendedPlan() {
    if (_plans.isEmpty) return null;
    return _plans.firstWhere(
      (plan) => plan.isPopular,
      orElse: () => _plans.first,
    );
  }

  // 获取最便宜的计划
  Plan? getCheapestPlan() {
    if (_plans.isEmpty) return null;
    return _plans.reduce((curr, next) => 
      (curr.lowestMonthlyPrice ?? double.infinity) < 
      (next.lowestMonthlyPrice ?? double.infinity) ? curr : next);
  }

  // 按周期筛选计划
  List<Plan> getPlansByPeriod(PlanPeriod period) {
    return _plans.where((plan) => 
      plan.pricing.getPriceForPeriod(period) != null).toList();
  }

  @override
  void dispose() {
    _plans.clear();
    _filteredPlans.clear();
    super.dispose();
  }
}


class PaymentMethodsViewModel extends ChangeNotifier {
  final String orderId;
  final PaymentSystem _paymentSystem;
  final OrderService _orderService;
  final ErrorHandler _errorHandler;
  
  PaymentProcessState _processState = const PaymentProcessState();
  PaymentProcessState get processState => _processState;

  PaymentMethodsViewModel({
    required this.orderId,
    required PaymentSystem paymentSystem,
    required OrderService orderService,
    required ErrorHandler errorHandler,
  })  : _paymentSystem = paymentSystem,
        _orderService = orderService,
        _errorHandler = errorHandler;

  Future<void> startPayment(PaymentProvider provider) async {
    if (_processState.isProcessing) return;

    try {
      _processState = _processState.copyWith(
        isProcessing: true,
        error: null,
        selectedProvider: provider,
      );
      notifyListeners();

      final result = await _paymentSystem.handlePayment(
        orderId: orderId,
        provider: provider,
      );

      _processState = _processState.copyWith(
        paymentData: result,
        isProcessing: false,
      );
      notifyListeners();

      if (result['requiresConfirmation'] == true) {
        await _confirmPayment(result);
      }
    } catch (e) {
      _processState = _processState.copyWith(
        isProcessing: false,
        error: _errorHandler.handleError(e),
      );
      notifyListeners();
    }
  }

  Future<void> _confirmPayment(Map<String, dynamic> paymentData) async {
    try {
      _processState = _processState.copyWith(isProcessing: true);
      notifyListeners();

      await _orderService.confirmPayment(
        orderId,
        paymentData,
        _processState.selectedProvider!,
      );

      _processState = _processState.copyWith(
        isProcessing: false,
        paymentData: {...paymentData, 'confirmed': true},
      );
      notifyListeners();
    } catch (e) {
      _processState = _processState.copyWith(
        isProcessing: false,
        error: _errorHandler.handleError(e),
      );
      notifyListeners();
    }
  }

  void reset() {
    _processState = const PaymentProcessState();
    notifyListeners();
  }
}

// 继续添加其他ViewModels...