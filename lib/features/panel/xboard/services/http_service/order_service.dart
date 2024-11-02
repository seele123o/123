// lib/features/panel/xboard/services/http_service/order_service.dart

import 'package:flutter/foundation.dart';
import '../error/error_handler.dart';
import '../storage/xboard_cache_manager.dart';
import '../analytics/analytics_service.dart';
import './http_service.dart';
import '../../models/order_model.dart';

class OrderService {
  final HttpService _httpService;
  final XboardCacheManager _cacheManager;
  final AnalyticsService _analytics;
  final ErrorHandler _errorHandler;

  OrderService({
    required HttpService httpService,
    required XboardCacheManager cacheManager,
    required AnalyticsService analytics,
    required ErrorHandler errorHandler,
  })  : _httpService = httpService,
        _cacheManager = cacheManager,
        _analytics = analytics,
        _errorHandler = errorHandler;

  // 创建订单
  Future<Map<String, dynamic>> createOrder(
    String accessToken,
    int planId,
    String period,
  ) async {
    try {
      _analytics.logEvent('create_order_attempt', {
        'plan_id': planId,
        'period': period,
      });

      final result = await _httpService.postRequest(
        "/api/v1/order/create",
        {
          'plan_id': planId,
          'period': period,
        },
        headers: {'Authorization': accessToken},
      );

      if (result['status'] != 'success') {
        _analytics.logError('create_order_failed', result['message']);
        throw Exception(result['message'] ?? 'Failed to create order');
      }

      _analytics.logEvent('create_order_success', {
        'order_id': result['data']['trade_no'],
      });

      return result['data'];
    } catch (e) {
      final errorMsg = _errorHandler.handleError(e);
      _analytics.logError('create_order_error', e);
      throw Exception(errorMsg);
    }
  }

  // 获取订单状态
  Future<Map<String, dynamic>> getOrderStatus(
    String tradeNo,
    String accessToken,
  ) async {
    try {
      final result = await _httpService.getRequest(
        "/api/v1/order/detail?trade_no=$tradeNo",
        headers: {'Authorization': accessToken},
      );

      if (result['status'] != 'success') {
        throw Exception(result['message'] ?? 'Failed to get order status');
      }

      return result['data'];
    } catch (e) {
      final errorMsg = _errorHandler.handleError(e);
      throw Exception(errorMsg);
    }
  }

  // 获取用户的订单列表
  Future<List<Order>> fetchUserOrders(String accessToken) async {
    try {
      final result = await _httpService.getRequest(
        "/api/v1/order/list",
        headers: {'Authorization': accessToken},
      );

      if (result['status'] != 'success') {
        throw Exception(result['message'] ?? 'Failed to fetch orders');
      }

      final List<dynamic> ordersData = result['data'];
      return ordersData.map((data) => Order.fromJson(data)).toList();
    } catch (e) {
      final errorMsg = _errorHandler.handleError(e);
      throw Exception(errorMsg);
    }
  }

  // 取消订单
  Future<void> cancelOrder(
    String tradeNo,
    String accessToken,
  ) async {
    try {
      _analytics.logEvent('cancel_order_attempt', {
        'trade_no': tradeNo,
      });

      final result = await _httpService.postRequest(
        "/api/v1/order/cancel",
        {'trade_no': tradeNo},
        headers: {'Authorization': accessToken},
      );

      if (result['status'] != 'success') {
        _analytics.logError('cancel_order_failed', result['message']);
        throw Exception(result['message'] ?? 'Failed to cancel order');
      }

      _analytics.logEvent('cancel_order_success', {
        'trade_no': tradeNo,
      });
    } catch (e) {
      final errorMsg = _errorHandler.handleError(e);
      _analytics.logError('cancel_order_error', e);
      throw Exception(errorMsg);
    }
  }

  // 获取支付方式列表
  Future<List<PaymentProvider>> getAvailablePaymentMethods(
    String orderId,
    String accessToken,
  ) async {
    try {
      final result = await _httpService.getRequest(
        "/api/v1/order/method?trade_no=$orderId",
        headers: {'Authorization': accessToken},
      );

      if (result['status'] != 'success') {
        throw Exception(result['message'] ?? 'Failed to get payment methods');
      }

      final List<dynamic> methods = result['data'];
      return methods.map((method) =>
        PaymentProvider.fromString(method.toString())
      ).toList();
    } catch (e) {
      final errorMsg = _errorHandler.handleError(e);
      throw Exception(errorMsg);
    }
  }

  // 通过缓存优化订单查询
  Future<Order?> getOrderFromCache(String orderId) async {
    return await _cacheManager.getCachedData<Order>(
      key: 'order_$orderId',
      fromJson: Order.fromJson,
    );
  }

  Future<void> cacheOrder(String orderId, Order order) async {
    await _cacheManager.cacheData(
      key: 'order_$orderId',
      data: order,
      duration: const Duration(minutes: 30),
    );
  }
}