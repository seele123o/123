// lib/features/panel/xboard/views/components/dialog/payment_methods_dialog.dart
import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/models/order_model.dart';
//import 'package:hiddify/features/panel/xboard/services/payment/payment_system.dart';
import 'package:hiddify/features/panel/xboard/services/subscription/subscription_service.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/dialog_viewmodel/payment_methods_viewmodel.dart';
//import 'package:hiddify/features/panel/xboard/viewmodels/dialog_viewmodel/payment_methods_viewmodel_provider.dart';
//import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hiddify/features/panel/xboard/providers/index.dart';

class PaymentMethodsDialog extends ConsumerStatefulWidget {
  final String orderId;
  final double amount;
  final String? period;
  final Function(bool success)? onPaymentComplete;

  const PaymentMethodsDialog({
    super.key,
    required this.orderId,
    required this.amount,
    this.period,
    this.onPaymentComplete,
  });

  @override
  _PaymentMethodsDialogState createState() => _PaymentMethodsDialogState();
}

class _PaymentMethodsDialogState extends ConsumerState<PaymentMethodsDialog> {
  late final PaymentMethodsViewModelParams _params;
  late final AutoDisposeChangeNotifierProvider<PaymentMethodsViewModel> _provider;

  @override
  void initState() {
    super.initState();
    _params = PaymentMethodsViewModelParams(
      orderId: widget.orderId,
      amount: widget.amount,
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
    );
    _provider = paymentMethodsViewModelProvider(_params);
  }

  void _handlePaymentSuccess() async {
    final t = ref.read(translationsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.purchase.orderSuccess)),
    );
    await Subscription.updateSubscription(context, ref);
    widget.onPaymentComplete?.call(true);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handlePaymentError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('支付失败: $error')),
    );
    widget.onPaymentComplete?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);
    final viewModel = ref.watch(_provider);
    final paymentMethods = ref.watch(availablePaymentMethodsProvider(widget.orderId));
    final paymentSystem = ref.watch(paymentSystemProvider);
    final config = ref.watch(paymentConfigProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: paymentMethods.when(
        data: (methods) => Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(t),
              const SizedBox(height: 16),
              _buildPriceInfo(t),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: methods
                        .map(
                          (method) => _buildPaymentMethodTile(
                            method: method,
                            viewModel: viewModel,
                            config: config.valueOrNull,
                            paymentSystem: paymentSystem,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFooter(t),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('加载支付方式失败: $error'),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t.general.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Translations t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          t.purchase.selectPaymentMethod,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildPriceInfo(Translations t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${t.purchase.orderAmount}: ¥${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.period != null) ...[
              const SizedBox(height: 8),
              Text(
                '${t.purchase.period}: ${widget.period}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required PaymentProvider method,
    required PaymentMethodsViewModel viewModel,
    required PaymentConfigModel? config,
    required PaymentSystem paymentSystem,
  }) {
    final isProcessing = viewModel.processingMethod == method;
    final fee = config?.getProviderFee(method) ?? 0.0;
    final totalAmount = widget.amount * (1 + fee / 100);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _getPaymentMethodIcon(method),
        title: Text(method.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getPaymentMethodDescription(method)),
            if (fee > 0)
              Text(
                '手续费: $fee%',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            Text(
              '总计: ¥${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        trailing: isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.arrow_forward_ios, size: 16),
        enabled: !viewModel.isProcessing && paymentSystem.isProviderInitialized(method),
        onTap: () => _handlePaymentMethodSelected(method, viewModel),
      ),
    );
  }

  Widget _getPaymentMethodIcon(PaymentProvider method) {
    switch (method) {
      case PaymentProvider.stripe:
        return Image.asset(
          'assets/images/payment/stripe_logo.png',
          width: 32,
          height: 32,
        );
      case PaymentProvider.revenuecat:
        return Image.asset(
          'assets/images/payment/revenuecat_logo.png',
          width: 32,
          height: 32,
        );
    }
  }

  String _getPaymentMethodDescription(PaymentProvider method) {
    switch (method) {
      case PaymentProvider.stripe:
        return '信用卡支付';
      case PaymentProvider.revenuecat:
        return '应用内购买';
    }
  }

  Widget _buildFooter(Translations t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.general.cancel),
        ),
      ],
    );
  }

  void _handlePaymentMethodSelected(
    PaymentProvider method,
    PaymentMethodsViewModel viewModel,
  ) async {
    try {
      await viewModel.startPayment(method);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('启动支付失败: $e')),
        );
      }
    }
  }
}
