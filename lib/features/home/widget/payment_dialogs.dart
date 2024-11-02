// lib/features/home/widget/payment_dialogs.dart
import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PaymentDialogs {
  static Future<void> showPaymentError(
    BuildContext context,
    WidgetRef ref, {
    required String message,
    String? details,
    VoidCallback? onRetry,
  }) async {
    final t = ref.read(translationsProvider);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.payment['errors']['generic']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (details != null) ...[
              const SizedBox(height: 8),
              Text(
                details,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.general.close),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(t.payment['actions']['retry']),
            ),
        ],
      ),
    );
  }

  static Future<bool> showPaymentConfirmation(
    BuildContext context,
    WidgetRef ref, {
    required double amount,
    required String provider,
    String? period,
  }) async {
    final t = ref.read(translationsProvider);

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.payment['actions']['confirm']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${t.payment['info']['total']}: '
                '${t.pricing['currency']['cny']}'
                '${amount.toStringAsFixed(2)}'),
            if (period != null) ...[
              const SizedBox(height: 8),
              Text('${t.payment['info']['period']}: $period'),
            ],
            const SizedBox(height: 16),
            Text(t.payment['methods'][provider]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.general.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.payment['actions']['confirm']),
          ),
        ],
      ),
    ) ?? false;
  }

  static Future<void> showPaymentProcessing(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final t = ref.read(translationsProvider);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(t.payment['messages']['processing']),
            ],
          ),
        ),
      ),
    );
  }
}

// 支付进度指示器组件
class PaymentProgressIndicator extends StatelessWidget {
  final double progress;
  final String message;
  final bool showCancel;
  final VoidCallback? onCancel;

  const PaymentProgressIndicator({
    Key? key,
    required this.progress,
    required this.message,
    this.showCancel = false,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 16),
        Text(message),
        if (showCancel && onCancel != null) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
        ],
      ],
    );
  }
}