// ignore_for_file: use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiddify/core/localization/translations.dart';
//import 'package:hiddify/features/panel/xboard/models/order_model.dart';
//import 'package:hiddify/features/panel/xboard/services/http_service/order_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hiddify/features/panel/xboard/providers/index.dart';

class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage> {
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchUserOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = _fetchUserOrders();
    });
  }

  Future<List<Order>> _fetchUserOrders() async {
    final accessToken = await getToken();
    if (accessToken == null) {
      throw Exception("No access token found.");
    }
    final orderService = ref.read(orderServiceProvider); // ✓ 通过 Provider 获取
    return await orderService.fetchUserOrders(accessToken);
  }

  String _getOrderStatusText(OrderStatus status, Translations t) {
    switch (status) {
      case OrderStatus.pending:
        return t.order.statuses.unpaid;
      case OrderStatus.completed:
        return t.order.statuses.paid;
      case OrderStatus.cancelled:
        return t.order.statuses.cancelled;
      case OrderStatus.processing:
        return '处理中';
      case OrderStatus.failed:
        return '支付失败';
      case OrderStatus.refunded:
        return '已退款';
      default:
        return t.order.statuses.unknown;
    }
  }

  String _formatTimestamp(int? timestamp, Translations t) {
    if (timestamp == null) return t.order.statuses.unknown;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  Widget _buildPaymentMethodChip(PaymentProvider provider) {
    IconData icon;
    Color color;
    switch (provider) {
      case PaymentProvider.stripe:
        icon = Icons.credit_card;
        color = Colors.blue;
        break;
      case PaymentProvider.revenuecat:
        icon = Icons.shop;
        color = Colors.green;
        break;
      default:
        icon = Icons.payment;
        color = Colors.grey;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        provider.displayName,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.order.title),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: FutureBuilder<List<Order>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(t.order.noOrders));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final order = snapshot.data![index];
                return _buildOrderCard(order, t);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order, Translations t) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onLongPress: () => _copyOrderNumber(order.tradeNo, t),
                    child: Text(
                      '${t.order.orderDetails.orderNumber}: ${order.tradeNo ?? t.order.statuses.unknown}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (order.paymentProvider != null) _buildPaymentMethodChip(order.paymentProvider),
              ],
            ),
            const SizedBox(height: 8),

            // 订单详情
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  t.order.orderDetails.amount,
                  '¥${(order.totalAmount ?? 0) / 100}',
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildDetailRow(
                  t.order.orderDetails.paymentCycle,
                  order.period ?? t.order.statuses.unknown,
                ),
                _buildDetailRow(
                  t.order.orderDetails.orderStatus,
                  _getOrderStatusText(order.status, t),
                  valueColor: _getStatusColor(order.status),
                ),
                _buildDetailRow(
                  t.order.orderDetails.orderTime,
                  _formatTimestamp(order.createdAt, t),
                ),
                if (order.expiryDate != null)
                  _buildDetailRow(
                    '到期时间',
                    _formatTimestamp(
                      order.expiryDate!.millisecondsSinceEpoch ~/ 1000,
                      t,
                    ),
                  ),
              ],
            ),

            // 订单错误信息
            if (order.errorMessage != null) ...[
              const Divider(),
              Text(
                order.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],

            // 操作按钮
            if (order.status.isPending || order.status.isProcessing) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order.status.isPending)
                    ElevatedButton(
                      onPressed: () => _showPaymentMethodsDialog(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(t.order.actions.pay),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleCancel(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(t.order.actions.cancel),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    TextStyle? textStyle,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: textStyle?.copyWith(color: valueColor) ?? TextStyle(color: valueColor),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodsDialog(Order order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PaymentMethodsSheet(
        order: order,
        onPaymentSelected: (provider) {
          Navigator.pop(context);
          _handlePayment(order, provider);
        },
      ),
    );
  }

  Future<void> _handlePayment(Order order, PaymentProvider provider) async {
    if (kDebugMode) {
      print('Processing payment for order: ${order.tradeNo} with $provider');
    }

    try {
      switch (provider) {
        case PaymentProvider.stripe:
          await _handleStripePayment(order);
          break;
        case PaymentProvider.revenuecat:
          await _handleRevenueCatPayment(order);
          break;
      }
    } catch (e) {
      _showSnackbar(context, '支付失败: $e');
    }
  }

  Future<void> _handleStripePayment(Order order) async {
    // TODO: 实现Stripe支付
  }

  Future<void> _handleRevenueCatPayment(Order order) async {
    // TODO: 实现RevenueCat支付
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.failed:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _copyOrderNumber(String? orderNumber, Translations t) {
    if (orderNumber == null) return;
    Clipboard.setData(ClipboardData(text: orderNumber));
    _showSnackbar(context, t.order.orderNumberCopied);
  }

  Future<void> _handleCancel(Order order) async {
    if (kDebugMode) {
      print('Cancelling order: ${order.tradeNo}');
    }

    try {
      final accessToken = await getToken();
      if (accessToken == null) throw Exception('No access token');

      final result = await OrderService().cancelOrder(
        order.tradeNo!,
        accessToken,
      );

      if (result['status'] == 'success') {
        _showSnackbar(
          context,
          ref.watch(translationsProvider).order.messages.orderCancelSuccess,
        );
        await _refreshOrders();
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      _showSnackbar(
        context,
        "${ref.watch(translationsProvider).order.messages.orderCancelFailed}: $e",
      );
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// 支付方式选择表单
class PaymentMethodsSheet extends StatelessWidget {
  final Order order;
  final Function(PaymentProvider) onPaymentSelected;

  const PaymentMethodsSheet({
    Key? key,
    required this.order,
    required this.onPaymentSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '选择支付方式',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('信用卡支付'),
            subtitle: const Text('Stripe'),
            onTap: () => onPaymentSelected(PaymentProvider.stripe),
          ),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('应用商店'),
            subtitle: const Text('RevenueCat'),
            onTap: () => onPaymentSelected(PaymentProvider.revenuecat),
          ),
        ],
      ),
    );
  }
}
