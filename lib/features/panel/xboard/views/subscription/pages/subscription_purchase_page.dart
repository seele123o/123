import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
//import '../services/revenuecat_service.dart';
//import '../viewmodels/subscription_purchase_viewmodel.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/providers/index.dart';

class SubscriptionPurchasePage extends ConsumerStatefulWidget {
  const SubscriptionPurchasePage({super.key});

  @override
  _SubscriptionPurchasePageState createState() => _SubscriptionPurchasePageState();
}

class _SubscriptionPurchasePageState extends ConsumerState<SubscriptionPurchasePage> {
  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final viewModel = ref.read(subscriptionPurchaseProvider.notifier);
    await viewModel.loadPackages();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);
    final viewModel = ref.watch(subscriptionPurchaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.subscription.choosePlan),
        actions: [
          TextButton(
            onPressed: () => _showRestoreDialog(context),
            child: Text(t.subscription.restorePurchases),
          ),
        ],
      ),
      body: viewModel.when(
        data: (packages) => _buildPackageList(packages, t),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${t.subscription.loadError}: $error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPackages,
                child: Text(t.general.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageList(List<Package> packages, Translations t) {
    if (packages.isEmpty) {
      return Center(
        child: Text(t.subscription.noPackagesAvailable),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        return _buildPackageCard(package, t);
      },
    );
  }

  Widget _buildPackageCard(Package package, Translations t) {
    final product = package.storeProduct;
    final viewModel = ref.read(subscriptionPurchaseProvider.notifier);
    final isPopular = package.identifier.contains('yearly');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Theme.of(context).colorScheme.primary,
              child: Text(
                t.subscription.mostPopular,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.priceString,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_getPeriodString(package, t).isNotEmpty)
                          Text(
                            _getPeriodString(package, t),
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFeaturesList(package, t),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handlePurchase(package, viewModel),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: isPopular
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    child: Text(t.subscription.subscribe),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(Package package, Translations t) {
    // 这里可以根据包标识返回不同的特性列表
    final features = _getFeaturesList(package, t);

    return Column(
      children: features.map((feature) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(feature)),
            ],
          ),
        ),
      ).toList(),
    );
  }

  List<String> _getFeaturesList(Package package, Translations t) {
    if (package.identifier.contains('yearly')) {
      return [
        t.subscription.features.unlimited,
        t.subscription.features.priority,
        t.subscription.features.noAds,
        t.subscription.features.support,
        '${t.subscription.features.savings} 20%',
      ];
    }

    return [
      t.subscription.features.unlimited,
      t.subscription.features.noAds,
      t.subscription.features.support,
    ];
  }

  String _getPeriodString(Package package, Translations t) {
    if (package.packageType == PackageType.monthly) {
      return t.subscription.perMonth;
    } else if (package.packageType == PackageType.annual) {
      return t.subscription.perYear;
    }
    return '';
  }

  Future<void> _handlePurchase(
    Package package,
    SubscriptionPurchaseViewModel viewModel,
  ) async {
    try {
      await viewModel.purchasePackage(package);
      if (mounted) {
        Navigator.of(context).pop(true); // 返回 true 表示购买成功
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t.subscription.purchaseError}: $e')),
        );
      }
    }
  }

  Future<void> _showRestoreDialog(BuildContext context) async {
    final t = ref.read(translationsProvider);
    final viewModel = ref.read(subscriptionPurchaseProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(t.subscription.restoringPurchases),
        content: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Please wait...'),
          ],
        ),
      ),
    );

    try {
      await viewModel.restorePurchases();
      if (mounted) {
        Navigator.of(context).pop(); // 关闭加载对话框
        Navigator.of(context).pop(true); // 返回上一页
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t.subscription.restoreError}: $e')),
        );
      }
    }
  }
}