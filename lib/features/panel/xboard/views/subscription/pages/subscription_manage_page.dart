import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/subscription/subscription_model.dart';
import 'package:hiddify/features/panel/xboard/service/subscription/subscription_manager.dart';
import 'package:hiddify/features/panel/xboard/services/payment/revenuecat_service.dart';
import 'package:hiddify/core/localization/translations.dart';
// 需要添加引用
import 'package:hiddify/core/notification/in_app_notification_controller.dart';
import 'package:hiddify/features/panel/xboard/notifier/subscription_notifier.dart';
import 'package:hiddify/features/panel/xboard/providers/index.dart';

class SubscriptionManagePage extends ConsumerWidget {
  const SubscriptionManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final subscription = ref.watch(subscriptionManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.subscription.manageTitle),
      ),
      body: subscription.when(
        data: (data) => _buildContent(context, data, t, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('${t.subscription.loadError}: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SubscriptionInfo subscription,
    Translations t,
    WidgetRef ref,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 订阅概览卡片
        _buildOverviewCard(context, subscription, t),

        const SizedBox(height: 16),

        // 管理选项卡片
        _buildManagementCard(context, subscription, t, ref),

        const SizedBox(height: 16),

        // 自动续期设置卡片 (如果支持)
        if (subscription.isActive && subscription.canConfigureAutoRenewal)
          _buildAutoRenewalCard(context, subscription, t, ref),

        const SizedBox(height: 16),

        // 账单历史
        _buildBillingHistoryCard(context, subscription, t),

        const SizedBox(height: 16),

        // 帮助和支持
        _buildSupportCard(context, t),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context,
    SubscriptionInfo subscription,
    Translations t,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.subscription.currentPlan,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              t.subscription.status,
              subscription.isActive
                ? Text(
                    t.subscription.statusActive,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    t.subscription.statusInactive,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
            if (subscription.isActive) ...[
              _buildInfoRow(
                t.subscription.plan,
                Text(subscription.planName ?? t.subscription.unknownPlan),
              ),
              if (subscription.expiryDate != null)
                _buildInfoRow(
                  t.subscription.nextBilling,
                  Text(subscription.expiryDate!.toString()),
                ),
              _buildInfoRow(
                t.subscription.paymentMethod,
                Row(
                  children: [
                    Icon(
                      _getPaymentMethodIcon(subscription.paymentMethod),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(_getPaymentMethodName(subscription.paymentMethod, t)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context,
    SubscriptionInfo subscription,
    Translations t,
    WidgetRef ref,
  ) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(t.subscription.changePlan),
            leading: const Icon(Icons.swap_horiz),
            onTap: () => _handleChangePlan(context),
          ),
          if (subscription.isActive) ...[
            const Divider(height: 1),
            ListTile(
              title: Text(t.subscription.cancelSubscription),
              leading: const Icon(Icons.cancel),
              onTap: () => _showCancelDialog(context, t, ref),
            ),
          ],
          const Divider(height: 1),
          ListTile(
            title: Text(t.subscription.restorePurchases),
            leading: const Icon(Icons.restore),
            onTap: () => _handleRestorePurchases(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoRenewalCard(
    BuildContext context,
    SubscriptionInfo subscription,
    Translations t,
    WidgetRef ref,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.subscription.autoRenewal,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(t.subscription.autoRenewalToggle),
              subtitle: Text(
                subscription.autoRenewEnabled
                  ? t.subscription.autoRenewalEnabled
                  : t.subscription.autoRenewalDisabled,
              ),
              value: subscription.autoRenewEnabled,
              onChanged: (value) => _handleAutoRenewalToggle(value, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingHistoryCard(
    BuildContext context,
    SubscriptionInfo subscription,
    Translations t,
  ) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              t.subscription.billingHistory,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (subscription.billingHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(t.subscription.noBillingHistory),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subscription.billingHistory.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final bill = subscription.billingHistory[index];
                return ListTile(
                  title: Text(bill.description),
                  subtitle: Text(bill.date.toString()),
                  trailing: Text(
                    bill.amount.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context, Translations t) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(t.subscription.helpCenter),
            leading: const Icon(Icons.help),
            onTap: () => _launchHelpCenter(),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(t.subscription.contactSupport),
            leading: const Icon(Icons.email),
            onTap: () => _launchSupport(),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(t.subscription.faq),
            leading: const Icon(Icons.question_answer),
            onTap: () => _launchFAQ(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          value,
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(String? method) {
    switch (method?.toLowerCase()) {
      case 'apple':
        return Icons.apple;
      case 'google':
        return Icons.android;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodName(String? method, Translations t) {
    switch (method?.toLowerCase()) {
      case 'apple':
        return 'Apple Pay';
      case 'google':
        return 'Google Pay';
      case 'card':
        return t.subscription.creditCard;
      default:
        return t.subscription.unknown;
    }
  }

  Future<void> _handleChangePlan(BuildContext context) async {
    Navigator.pushNamed(context, '/subscription/change-plan');
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    Translations t,
    WidgetRef ref,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.subscription.cancelConfirmTitle),
        content: Text(t.subscription.cancelConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.general.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.general.confirm),
          ),
        ],
      ),
    );

    if (result == true) {
      await _handleCancelSubscription(context, ref);
    }
  }

  Future<void> _handleCancelSubscription(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final t = ref.read(translationsProvider);

    try {
      // 显示加载指示器
      _showLoadingDialog(context);

      // 执行取消订阅
      await RevenueCatService.cancelSubscription();

      // 刷新订阅状态
      ref.refresh(subscriptionManagerProvider);

      if (context.mounted) {
        Navigator.pop(context); // 关闭加载指示器

        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.subscription.cancelSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // 关闭加载指示器

        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t.subscription.cancelError}: $e')),
        );
      }
    }
  }

  Future<void> _handleRestorePurchases(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final t = ref.read(translationsProvider);

    try {
      // 显示加载指示器
      _showLoadingDialog(context);

      // 执行恢复购买
      await RevenueCatService.restorePurchases();

      // 刷新订阅状态
      ref.refresh(subscriptionManagerProvider);

      if (context.mounted) {
        Navigator.pop(context); // 关闭加载指示器

        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.subscription.restoreSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // 关闭加载指示器

        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t.subscription.restoreError}: $e')),
        );
      }
    }
  }

  Future<void> _handleAutoRenewalToggle(bool value, WidgetRef ref) async {
    // 这里实现自动续期开关的逻辑
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _launchHelpCenter() async {
    final url = Uri.parse('https://your-domain.com/help');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchSupport() async {
    final url = Uri.parse('mailto:support@your-domain.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchFAQ() async {
    final url = Uri.parse('https://your-domain.com/faq');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}