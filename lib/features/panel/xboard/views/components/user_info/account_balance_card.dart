// views/account_balance_card.dart
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/models/user_info_model.dart';
//import 'package:hiddify/features/panel/xboard/services/http_service/balance.service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/user_info_viewmodel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../dialog/cancel_subscription_dialog.dart';

class AccountBalanceCard extends ConsumerWidget {
  const AccountBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final userInfoAsync = ref.watch(userInfoProvider);

    return userInfoAsync.when(
      data: (userInfo) {
        if (userInfo == null) {
          return Center(child: Text(t.userInfo.noData));
        }
        return _buildAccountBalanceCard(userInfo, t, context, ref);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('${t.userInfo.fetchUserInfoError} $error'),
      ),
    );
  }

  Widget _buildAccountBalanceCard(
    UserInfo userInfo,
    Translations t,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        children: [
          // 账户余额部分
          Container(
            height: 96,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListTile(
              leading: const Icon(FluentIcons.wallet_24_filled),
              title: Text(
                '${t.userInfo.balance} (${t.userInfo.onlyForConsumption})',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(userInfo.balance / 100).toStringAsFixed(2)} ${t.userInfo.currency}',
                  ),
                  if (userInfo.hasActiveSubscription) 
                    Text(
                      '当前订阅: ${_getSubscriptionInfo(userInfo)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              trailing: userInfo.hasActiveSubscription
                  ? Icon(
                      Icons.verified,
                      color: Colors.green,
                      size: 20,
                    )
                  : null,
            ),
          ),
          const Divider(height: 1),
          
          // 佣金余额部分
          Container(
            height: 96,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListTile(
              leading: const Icon(FluentIcons.gift_card_money_24_filled),
              title: Text(t.userInfo.commissionBalance),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(userInfo.commissionBalance / 100).toStringAsFixed(2)} ${t.userInfo.currency}',
                  ),
                  if (userInfo.commissionRate != null)
                    Text(
                      '佣金比例: ${(userInfo.commissionRate! * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 操作按钮部分
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showTransferDialog(context, ref, userInfo),
                      child: Text(t.transferDialog.transfer),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showWithdrawDialog(
                        context,
                        ref,
                        userInfo.commissionBalance,
                      ),
                      child: Text(t.transferDialog.withdraw),
                    ),
                  ],
                ),
                if (!userInfo.hasActiveSubscription) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => showCancelSubscriptionDialog(context, userInfo),
                    icon: const Icon(Icons.cancel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    label: const Text('取消订阅'),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showSubscriptionDialog(context, ref),
                    icon: const Icon(Icons.card_giftcard),
                    label: const Text('购买订阅'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getSubscriptionInfo(UserInfo userInfo) {
    if (userInfo.subscriptionEndDate == null) return '永久会员';
    final endDate = DateTime.fromMillisecondsSinceEpoch(userInfo.subscriptionEndDate!);
    final remaining = endDate.difference(DateTime.now());
    
    if (remaining.inDays > 0) {
      return '剩余 ${remaining.inDays} 天';
    }
    return '即将到期';
  }

  // 现有的转账对话框实现...

  // 现有的提现对话框实现...

  void _showSubscriptionDialog(BuildContext context, WidgetRef ref) {
    final t = ref.read(translationsProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.subscription.choosePaymentMethod),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Image.asset(
                'assets/stripe_logo.png',
                width: 24,
                height: 24,
              ),
              title: const Text('Stripe'),
              subtitle: const Text('信用卡支付'),
              onTap: () {
                Navigator.pop(context);
                _handleStripePayment(context, ref);
              },
            ),
            ListTile(
              leading: Image.asset(
                'assets/revenuecat_logo.png',
                width: 24,
                height: 24,
              ),
              title: const Text('RevenueCat'),
              subtitle: const Text('App Store / Google Play'),
              onTap: () {
                Navigator.pop(context);
                _handleRevenueCatPayment(context, ref);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.ensure.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStripePayment(BuildContext context, WidgetRef ref) async {
    // TODO: 实现 Stripe 支付流程
  }

  Future<void> _handleRevenueCatPayment(BuildContext context, WidgetRef ref) async {
    // TODO: 实现 RevenueCat 支付流程
  }
}