// lib/core/widget/payment/payment_loading_overlay.dart
import 'package:flutter/material.dart';

class PaymentLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;

  const PaymentLoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.loadingText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (loadingText != null) ...[
                        const SizedBox(height: 16),
                        Text(loadingText!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// lib/core/widget/payment/purchase_error_view.dart
class PurchaseErrorView extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const PurchaseErrorView({
    Key? key,
    required this.error,
    this.onRetry,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '支付出现问题',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRetry != null)
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('重试'),
                  ),
                if (onRetry != null && onCancel != null)
                  const SizedBox(width: 16),
                if (onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('取消'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// lib/core/widget/payment/subscription_countdown_timer.dart
class SubscriptionCountdownTimer extends StatefulWidget {
  final DateTime expiryDate;
  final TextStyle? textStyle;
  final VoidCallback? onExpired;

  const SubscriptionCountdownTimer({
    Key? key,
    required this.expiryDate,
    this.textStyle,
    this.onExpired,
  }) : super(key: key);

  @override
  State<SubscriptionCountdownTimer> createState() => _SubscriptionCountdownTimerState();
}

class _SubscriptionCountdownTimerState extends State<SubscriptionCountdownTimer> {
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    if (now.isAfter(widget.expiryDate)) {
      _remainingTime = Duration.zero;
      widget.onExpired?.call();
      _timer.cancel();
    } else {
      setState(() {
        _remainingTime = widget.expiryDate.difference(now);
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(_remainingTime),
      style: widget.textStyle,
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}天${duration.inHours % 24}小时';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}小时${duration.inMinutes % 60}分钟';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分钟${duration.inSeconds % 60}秒';
    } else {
      return '${duration.inSeconds}秒';
    }
  }
}

// lib/core/widget/payment/payment_confirmation_dialog.dart
class PaymentConfirmationDialog extends StatelessWidget {
  final String planName;
  final String price;
  final String? description;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PaymentConfirmationDialog({
    Key? key,
    required this.planName,
    required this.price,
    this.description,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('确认购买'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('套餐：$planName'),
          const SizedBox(height: 8),
          Text('价格：$price'),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(description!),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text('确认'),
        ),
      ],
    );
  }
}

// lib/core/widget/payment/restored_purchases_view.dart
class RestoredPurchasesView extends StatelessWidget {
  final List<RestorablePurchase> purchases;
  final VoidCallback? onClose;

  const RestoredPurchasesView({
    Key? key,
    required this.purchases,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '已恢复的购买',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (purchases.isEmpty)
          const Text('未找到可恢复的购买')
        else
          ListView.builder(
            shrinkWrap: true,
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index];
              return ListTile(
                title: Text(purchase.productName),
                subtitle: Text(
                  '购买时间: ${_formatDate(purchase.purchaseDate)}',
                ),
                trailing: Text(
                  purchase.isActive ? '有效' : '已过期',
                  style: TextStyle(
                    color: purchase.isActive ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        if (onClose != null)
          ElevatedButton(
            onPressed: onClose,
            child: const Text('关闭'),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class RestorablePurchase {
  final String productName;
  final DateTime purchaseDate;
  final bool isActive;

  RestorablePurchase({
    required this.productName,
    required this.purchaseDate,
    required this.isActive,
  });
}