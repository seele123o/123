import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/order_service.dart';
import 'package:hiddify/features/panel/xboard/core/config/payment_config.dart';

class MonitorPayStatus {
  final OrderService _orderService;

  MonitorPayStatus({
    required OrderService orderService,
  }) : _orderService = orderService;

  // 启动支付状态监控
  Future<void> startMonitoring(
    String orderId,
    PaymentProvider provider,
    String accessToken,
    Function(bool) onPaymentStatusChanged,
  ) async {
    // 调用监控订单状态的方法
    await monitorOrderStatus(orderId, accessToken, onPaymentStatusChanged);
  }

  // 监控订单状态，轮询20分钟后停止
  Future<void> monitorOrderStatus(
    String tradeNo,
    String accessToken,
    Function(bool) onPaymentStatusChanged,
  ) async {
    bool isPaymentComplete = false;
    const int maxPollingDuration = 20 * 60; // 20 minutes in seconds
    int elapsedTime = 0;

    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (isPaymentComplete || elapsedTime >= maxPollingDuration) {
        timer.cancel(); // 支付完成或超时后停止轮询
        return;
      }

      elapsedTime += 10; // 每次轮询增加10秒

      try {
        final orderDetails = await _getOrderDetails(tradeNo, accessToken);

        if (orderDetails['status'] == 'success') {
          final orderData = orderDetails['data'];

          // 检查订单是否被取消
          if (orderData['status'] is int && orderData['status'] == 2) {
            isPaymentComplete = true; // 停止轮询
            timer.cancel();
            return;
          }

          // 检查订单是否已支付
          if (orderData['status'] is int && orderData['status'] == 0) {
            onPaymentStatusChanged(false); // 通知支付未完成
          } else if (orderData['status'] is int && orderData['status'] == 3) {
            isPaymentComplete = true; // 标记支付完成
            onPaymentStatusChanged(true); // 通知支付完成
            timer.cancel(); // 停止轮询
          }
        } else {
          print("Failed to get valid order status: ${orderDetails['message']}");
        }
      } catch (e) {
        print("Error while checking order status: $e");
      }
    });
  }

  // 获取订单详情的函数
  Future<Map<String, dynamic>> _getOrderDetails(String tradeNo, String accessToken) async {
    try {
      final orderDetails = await _orderService.getOrderDetails(tradeNo, accessToken);
      return orderDetails;
    } catch (e) {
      throw Exception("Failed to fetch order details: $e");
    }
  }
}

// Provider
final monitorPayStatusProvider = Provider((ref) {
  final orderService = ref.watch(orderServiceProvider);
  return MonitorPayStatus(orderService: orderService);
});
