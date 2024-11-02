// lib/features/home/widget/payment_summary_card.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/models/order_model.dart';
import 'package:hiddify/features/panel/xboard/models/payment_process_state.dart';
import 'package:hiddify/features/panel/xboard/constants/payment_constants.dart';

class PaymentSummaryCard extends ConsumerWidget {
  final double amount;
  final double? feeRate;
  final String? period;
  final PaymentProvider? provider;
  final VoidCallback? onChangeProvider;
  final PaymentStatus status;

  const PaymentSummaryCard({
    Key? key,
    required this.amount,
    this.feeRate,
    this.period,
    this.provider,
    this.onChangeProvider,
    this.status = PaymentStatus.initial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final theme = Theme.of(context);
    final processingFee = (feeRate != null) ? (amount * feeRate! / 100) : 0.0;
    final totalAmount = amount + processingFee;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.payment['info']['total'],
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  _formatPrice(totalAmount),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildDetailsSection(theme, t),
            if (status != PaymentStatus.initial) ...[
              const Divider(),
              _buildStatusSection(theme, t),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(ThemeData theme, Translations t) {
    return Column(
      children: [
        _buildDetailRow(
          t.payment['info']['original'],
          _formatPrice(amount),
          theme,
        ),
        if (feeRate != null && feeRate! > 0)
          _buildDetailRow(
            t.payment['info']['fee'].replaceAll(
              '{percent}',
              feeRate!.toStringAsFixed(1),
            ),
            _formatPrice(amount * feeRate! / 100),
            theme,
            style: theme.textTheme.bodySmall,
          ),
        if (period != null)
          _buildDetailRow(
            t.payment['info']['period'],
            period!,
            theme,
          ),
        if (provider != null) _buildPaymentMethodRow(theme, t),
      ],
    );
  }

  Widget _buildPaymentMethodRow(ThemeData theme, Translations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            t.payment['methods']['title'],
            style: theme.textTheme.bodyMedium,
          ),
          if (onChangeProvider != null)
            TextButton.icon(
              onPressed: onChangeProvider,
              icon: Text(provider!.displayName),
              label: const Icon(Icons.arrow_forward_ios, size: 16),
            )
          else
            Text(provider!.displayName),
        ],
      ),
    );
  }

  Widget _buildStatusSection(ThemeData theme, Translations t) {
    return Row(
      children: [
        _getStatusIcon(),
        const SizedBox(width: 8),
        Text(
          _getStatusText(t),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: _getStatusColor(theme),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    ThemeData theme, {
    TextStyle? style,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style ?? theme.textTheme.bodyMedium),
          Text(value, style: style ?? theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return '${PaymentConstants.defaultCurrency} ${price.toStringAsFixed(PaymentConstants.defaultDecimalPlaces)}';
  }

  Widget _getStatusIcon() {
    IconData iconData;
    Color color;

    switch (status) {
      case PaymentStatus.processing:
        iconData = Icons.sync;
        color = Colors.blue;
        break;
      case PaymentStatus.completed:
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case PaymentStatus.failed:
        iconData = Icons.error;
        color = Colors.red;
        break;
      case PaymentStatus.cancelled:
        iconData = Icons.cancel;
        color = Colors.grey;
        break;
      case PaymentStatus.refunded:
        iconData = Icons.replay;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.pending;
        color = Colors.grey;
    }

    return Icon(iconData, color: color, size: 20);
  }

  String _getStatusText(Translations t) {
    return t.payment['status'][status.toString().split('.').last];
  }

  Color _getStatusColor(ThemeData theme) {
    switch (status) {
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.cancelled:
      case PaymentStatus.refunded:
        return Colors.grey;
      default:
        return theme.textTheme.bodyMedium?.color ?? Colors.black;
    }
  }
}
