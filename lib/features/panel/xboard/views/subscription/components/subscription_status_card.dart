import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/subscription_model.dart';
import '../services/subscription_manager.dart';
import '../core/localization/translations.dart';

class SubscriptionStatusCard extends ConsumerWidget {
  const SubscriptionStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final subscription = ref.watch(subscriptionManagerProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: subscription.when(
        data: (data) => _buildSubscriptionInfo(context, data, t),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${t.subscription.statusError}: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(subscriptionManagerProvider),
                child: Text(t.general.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionInfo(
    BuildContext context,
    SubscriptionInfo subscription,
    Translations t,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 状态头部
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: subscription.isActive
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Icon(
                subscription.isActive
                  ? Icons.check_circle
                  : Icons.error,
                color: subscription.isActive
                  ? Colors.green
                  : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.isActive
                        ? t.subscription.statusActive
                        : t.subscription.statusInactive,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subscription.isActive && subscription.expiryDate != null)
                      Text(
                        _getExpiryText(subscription.expiryDate!, t),
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 订阅详情
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subscription.isActive) ...[
                _buildDetailRow(
                  t.subscription.plan,
                  subscription.planName ?? t.subscription.unknownPlan,
                  theme,
                ),
                const SizedBox(height: 8),
                if (subscription.dataLimit != null) ...[
                  _buildProgressBar(
                    label: t.subscription.dataUsage,
                    current: subscription.dataUsed ?? 0,
                    max: subscription.dataLimit!,
                    formatValue: _formatDataSize,
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                ],
                if (subscription.devicesLimit != null) ...[
                  _buildProgressBar(
                    label: t.subscription.devicesUsage,
                    current: subscription.devicesCount ?? 0,
                    max: subscription.devicesLimit!,
                    formatValue: (value) => value.toString(),
                    theme: theme,
                  ),
                ],
              ],

              const SizedBox(height: 16),

              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!subscription.isActive)
                    ElevatedButton(
                      onPressed: () => _showSubscriptionPurchase(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(t.subscription.subscribe),
                    )
                  else ...[
                    OutlinedButton(
                      onPressed: () => _showSubscriptionDetails(context),
                      child: Text(t.subscription.details),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showManageSubscription(context),
                      child: Text(t.subscription.manage),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required String label,
    required num current,
    required num max,
    required String Function(num) formatValue,
    required ThemeData theme,
  }) {
    final progress = (current / max).clamp(0.0, 1.0);
    final percentage = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
            Text(
              '${formatValue(current)} / ${formatValue(max)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          color: percentage > 90
            ? Colors.red
            : percentage > 75
              ? Colors.orange
              : theme.colorScheme.primary,
        ),
      ],
    );
  }

  String _getExpiryText(DateTime expiryDate, Translations t) {
    final remaining = expiryDate.difference(DateTime.now());

    if (remaining.isNegative) {
      return t.subscription.expired;
    }

    if (remaining.inDays > 30) {
      return t.subscription.expiresOn(expiryDate.toString());
    }

    if (remaining.inDays > 0) {
      return t.subscription.expiresInDays(remaining.inDays);
    }

    if (remaining.inHours > 0) {
      return t.subscription.expiresInHours(remaining.inHours);
    }

    return t.subscription.expiresInMinutes(remaining.inMinutes);
  }

  String _formatDataSize(num bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  void _showSubscriptionPurchase(BuildContext context) {
    Navigator.pushNamed(context, '/subscription/purchase');
  }

  void _showSubscriptionDetails(BuildContext context) {
    Navigator.pushNamed(context, '/subscription/details');
  }

  void _showManageSubscription(BuildContext context) {
    Navigator.pushNamed(context, '/subscription/manage');
  }
}