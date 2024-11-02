import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hiddify/features/panel/xboard/services/payment/revenuecat_service.dart';
import '../pages/subscription_manager.dart';
import 'package:hiddify/core/localization/translations.dart';

class SubscriptionSettingsPage extends ConsumerStatefulWidget {
  const SubscriptionSettingsPage({super.key});

  @override
  _SubscriptionSettingsPageState createState() => _SubscriptionSettingsPageState();
}

class _SubscriptionSettingsPageState extends ConsumerState<SubscriptionSettingsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);
    final subscription = ref.watch(subscriptionManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.subscription.settingsTitle),
      ),
      body: subscription.when(
        data: (data) => _buildSettings(data, t),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('${t.subscription.loadError}: $error'),
        ),
      ),
    );
  }

  Widget _buildSettings(SubscriptionInfo subscription, Translations t) {
    if (!subscription.isActive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_membership_outlined,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(t.subscription.noActiveSubscription),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/subscription/purchase'),
              child: Text(t.subscription.subscribe),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        // 自动续订设置
        if (subscription.canConfigureAutoRenewal) ...[
          _buildAutoRenewalSection(subscription, t),
          const Divider(height: 32),
        ],

        // 价格和计费周期
        _buildBillingSection(subscription, t),
        const Divider(height: 32),

        // 通知设置
        _buildNotificationSection(t),
        const Divider(height: 32),

        // 取消订阅按钮
        _buildCancelSection(t),
      ],
    );
  }

  Widget _buildAutoRenewalSection(SubscriptionInfo subscription, Translations t) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.subscription.autoRenewal,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            t.subscription.autoRenewalDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(t.subscription.enableAutoRenewal),
            subtitle: Text(
              subscription.autoRenewEnabled
                ? t.subscription.autoRenewalEnabled
                : t.subscription.autoRenewalDisabled,
            ),
            value: subscription.autoRenewEnabled,
            onChanged: _isLoading ? null : (value) => _handleAutoRenewalToggle(value),
          ),
          if (subscription.expiryDate != null) ...[
            const SizedBox(height: 8),
            Text(
              subscription.autoRenewEnabled
                ? t.subscription.nextRenewalDate(subscription.expiryDate!.toString())
                : t.subscription.expiryDate(subscription.expiryDate!.toString()),
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillingSection(SubscriptionInfo subscription, Translations t) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.subscription.billingInfo,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            t.subscription.currentPlan,
            subscription.planName ?? t.subscription.unknown,
          ),
          _buildInfoRow(
            t.subscription.billingCycle,
            _getBillingCycleText(subscription.period, t),
          ),
          _buildInfoRow(
            t.subscription.price,
            subscription.formattedPrice ?? t.subscription.unknown,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/subscription/history'),
            child: Text(t.subscription.viewBillingHistory),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(Translations t) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.subscription.notifications,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(t.subscription.expiryNotification),
            subtitle: Text(t.subscription.expiryNotificationDescription),
            value: true, // TODO: 从设置获取实际值
            onChanged: (value) {
              // TODO: 实现通知设置更新
            },
          ),
          SwitchListTile(
            title: Text(t.subscription.renewalNotification),
            subtitle: Text(t.subscription.renewalNotificationDescription),
            value: true, // TODO: 从设置获取实际值
            onChanged: (value) {
              // TODO: 实现通知设置更新
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCancelSection(Translations t) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.subscription.cancelSubscription,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            t.subscription.cancelDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: Text(t.subscription.cancelButton),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getBillingCycleText(String? period, Translations t) {
    switch (period?.toLowerCase()) {
      case 'monthly':
        return t.subscription.monthly;
      case 'yearly':
        return t.subscription.yearly;
      case 'lifetime':
        return t.subscription.lifetime;
      default:
        return t.subscription.unknown;
    }
  }

  Future<void> _handleAutoRenewalToggle(bool value) async {
    final t = ref.read(translationsProvider);

    setState(() => _isLoading = true);

    try {
      await RevenueCatService.setAutoRenewal(value);

      // 刷新订阅状态
      ref.refresh(subscriptionManagerProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                ? t.subscription.autoRenewalEnabled
                : t.subscription.autoRenewalDisabled,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.subscription.settingsError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showCancelDialog() async {
    final t = ref.read(translationsProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.subscription.cancelConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.subscription.cancelConfirmMessage),
            const SizedBox(height: 16),
            Text(
              t.subscription.cancelWarning,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.general.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.subscription.cancelButton),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _handleCancelSubscription();
    }
  }

  Future<void> _handleCancelSubscription() async {
    final t = ref.read(translationsProvider);

    setState(() => _isLoading = true);

    try {
      await RevenueCatService.cancelSubscription();

      // 刷新订阅状态
      ref.refresh(subscriptionManagerProvider);

      if (mounted) {
        Navigator.pop(context); // 返回上一页

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.subscription.cancelSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.subscription.cancelError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}