import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription/subscription_model.dart';
import '../services/revenuecat_service.dart';
import 'package:hiddify/core/localization/translations.dart';

class TransactionHistory {
  final String id;
  final DateTime date;
  final String type;
  final double amount;
  final String currency;
  final String productId;
  final String status;
  final bool isRefunded;
  final Map<String, dynamic>? metadata;

  TransactionHistory({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.currency,
    required this.productId,
    required this.status,
    this.isRefunded = false,
    this.metadata,
  });
}

// 交易历史状态 Provider
final transactionHistoryProvider = StateNotifierProvider<TransactionHistoryNotifier, AsyncValue<List<TransactionHistory>>>((ref) {
  return TransactionHistoryNotifier();
});

class TransactionHistoryNotifier extends StateNotifier<AsyncValue<List<TransactionHistory>>> {
  TransactionHistoryNotifier() : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      state = const AsyncValue.loading();

      // 获取交易历史
      final customerInfo = await RevenueCatService.getCustomerInfo();
      final transactions = _parseTransactions(customerInfo);

      state = AsyncValue.data(transactions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  List<TransactionHistory> _parseTransactions(CustomerInfo customerInfo) {
    final transactions = <TransactionHistory>[];

    // 解析所有历史交易
    if (customerInfo.nonSubscriptionTransactions.isNotEmpty) {
      for (final transaction in customerInfo.nonSubscriptionTransactions) {
        transactions.add(
          TransactionHistory(
            id: transaction.transactionIdentifier,
            date: transaction.purchaseDate,
            type: 'one_time',
            amount: transaction.price,
            currency: transaction.currency,
            productId: transaction.productIdentifier,
            status: transaction.verified ? 'completed' : 'pending',
            isRefunded: transaction.isRefunded,
          ),
        );
      }
    }

    // 解析订阅交易
    for (final entitlement in customerInfo.entitlements.active.values) {
      for (final transaction in entitlement.transactions) {
        transactions.add(
          TransactionHistory(
            id: transaction.transactionIdentifier,
            date: transaction.purchaseDate,
            type: 'subscription',
            amount: transaction.price,
            currency: transaction.currency,
            productId: transaction.productIdentifier,
            status: transaction.verified ? 'completed' : 'pending',
            isRefunded: transaction.isRefunded,
          ),
        );
      }
    }

    // 按日期排序
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }
}

class SubscriptionHistoryPage extends ConsumerWidget {
  const SubscriptionHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final transactions = ref.watch(transactionHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.subscription.transactionHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(transactionHistoryProvider.notifier).loadTransactions(),
            tooltip: t.general.refresh,
          ),
        ],
      ),
      body: transactions.when(
        data: (data) => _buildTransactionList(data, t, context),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${t.subscription.loadError}: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(transactionHistoryProvider.notifier).loadTransactions(),
                child: Text(t.general.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    List<TransactionHistory> transactions,
    Translations t,
    BuildContext context,
  ) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(t.subscription.noTransactions),
          ],
        ),
      );
    }

    // 按月份分组交易
    final grouped = <String, List<TransactionHistory>>{};
    for (final transaction in transactions) {
      final monthKey = DateFormat('MMMM yyyy').format(transaction.date);
      grouped.putIfAbsent(monthKey, () => []).add(transaction);
    }

    return ListView.builder(
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final monthKey = grouped.keys.elementAt(index);
        final monthTransactions = grouped[monthKey]!;

        return _buildMonthSection(monthKey, monthTransactions, t, context);
      },
    );
  }

  Widget _buildMonthSection(
    String month,
    List<TransactionHistory> transactions,
    Translations t,
    BuildContext context,
  ) {
    // 计算月度总支出
    final monthTotal = transactions.fold<double>(
      0,
      (total, tx) => total + (tx.isRefunded ? 0 : tx.amount),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                month,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${t.subscription.total}: ${_formatCurrency(monthTotal, transactions.first.currency)}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) =>
            _buildTransactionTile(transactions[index], t, context),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildTransactionTile(
    TransactionHistory transaction,
    Translations t,
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(
        _getTransactionTitle(transaction, t),
        style: transaction.isRefunded
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMM d, yyyy HH:mm').format(transaction.date),
            style: theme.textTheme.bodySmall,
          ),
          Text(
            transaction.productId,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatCurrency(transaction.amount, transaction.currency),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.isRefunded
                  ? theme.disabledColor
                  : theme.colorScheme.onSurface,
              decoration: transaction.isRefunded
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          _buildStatusChip(transaction, theme),
        ],
      ),
      onTap: () => _showTransactionDetails(context, transaction, t),
    );
  }

  Widget _buildStatusChip(TransactionHistory transaction, ThemeData theme) {
    Color color;
    String text;

    if (transaction.isRefunded) {
      color = Colors.orange;
      text = 'Refunded';
    } else if (transaction.status == 'completed') {
      color = Colors.green;
      text = 'Completed';
    } else {
      color = Colors.grey;
      text = transaction.status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getTransactionTitle(TransactionHistory transaction, Translations t) {
    if (transaction.type == 'subscription') {
      return t.subscription.subscriptionRenewal;
    } else {
      return t.subscription.oneTimePurchase;
    }
  }

  String _formatCurrency(double amount, String currency) {
    final format = NumberFormat.currency(
      symbol: currency,
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  void _showTransactionDetails(
    BuildContext context,
    TransactionHistory transaction,
    Translations t,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  t.subscription.transactionDetails,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                _buildDetailRow(t.subscription.transactionId, transaction.id),
                _buildDetailRow(t.subscription.date,
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.date)),
                _buildDetailRow(t.subscription.type,
                  transaction.type == 'subscription'
                    ? t.subscription.subscriptionPurchase
                    : t.subscription.oneTimePurchase),
                _buildDetailRow(t.subscription.amount,
                  _formatCurrency(transaction.amount, transaction.currency)),
                _buildDetailRow(t.subscription.productId, transaction.productId),
                _buildDetailRow(t.subscription.status,
                  transaction.isRefunded
                    ? t.subscription.refunded
                    : transaction.status),
                if (transaction.metadata != null) ...[
                  const Divider(height: 24),
                  Text(
                    t.subscription.additionalInfo,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...transaction.metadata!.entries.map((e) =>
                    _buildDetailRow(e.key, e.value.toString()),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}