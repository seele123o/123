// lib/core/widget/payment_status_card.dart
import 'package:flutter/material.dart';

class PaymentStatusCard extends StatelessWidget {
  final String status;
  final String? message;
  final VoidCallback? onRetry;

  const PaymentStatusCard({
    Key? key,
    required this.status,
    this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(),
            const SizedBox(height: 8),
            Text(
              _getStatusText(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (message != null) ...[
              const SizedBox(height: 4),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null && status == 'failed') ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData iconData;
    Color color;

    switch (status) {
      case 'success':
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case 'failed':
        iconData = Icons.error;
        color = Colors.red;
        break;
      case 'processing':
        iconData = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.info;
        color = Colors.blue;
    }

    return Icon(
      iconData,
      size: 48,
      color: color,
    );
  }

  String _getStatusText() {
    switch (status) {
      case 'success':
        return '支付成功';
      case 'failed':
        return '支付失败';
      case 'processing':
        return '处理中';
      default:
        return '未知状态';
    }
  }
}

// lib/core/widget/subscription_info_card.dart
class SubscriptionInfoCard extends StatelessWidget {
  final String? planName;
  final DateTime? expiryDate;
  final bool isActive;
  final VoidCallback? onRenew;

  const SubscriptionInfoCard({
    Key? key,
    this.planName,
    this.expiryDate,
    required this.isActive,
    this.onRenew,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isActive ? Icons.verified : Icons.warning,
                  color: isActive ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  '订阅状态',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (planName != null) ...[
              Text(
                '当前套餐: $planName',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
            ],
            if (expiryDate != null) ...[
              Text(
                '到期时间: ${_formatDate(expiryDate!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
            ],
            if (!isActive && onRenew != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRenew,
                  child: const Text('续订'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// lib/core/widget/payment_method_card.dart
class PaymentMethodCard extends StatelessWidget {
  final String name;
  final String? description;
  final Widget? icon;
  final bool isSelected;
  final VoidCallback onSelect;

  const PaymentMethodCard({
    Key? key,
    required this.name,
    this.description,
    this.icon,
    required this.isSelected,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 2 : 1,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
            ],
          ),
        ),
      ),
    );
  }
}