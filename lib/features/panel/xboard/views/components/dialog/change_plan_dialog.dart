import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenuecat_service.dart';
import '../models/subscription_model.dart';
import '../core/localization/translations.dart';

class SubscriptionChangePlanPage extends ConsumerStatefulWidget {
  const SubscriptionChangePlanPage({super.key});

  @override
  _SubscriptionChangePlanPageState createState() => _SubscriptionChangePlanPageState();
}

class _SubscriptionChangePlanPageState extends ConsumerState<SubscriptionChangePlanPage> {
  AsyncValue<List<Package>> _packages = const AsyncValue.loading();
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await RevenueCatService.getAvailablePackages();

      // 过滤出升级/降级选项
      final currentSubscription = await RevenueCatService.checkSubscriptionStatus();
      final filteredPackages = _filterEligiblePackages(packages, currentSubscription);

      setState(() {
        _packages = AsyncValue.data(filteredPackages);
      });
    } catch (e) {
      setState(() {
        _packages = AsyncValue.error(e, StackTrace.current);
      });
    }
  }

  List<Package> _filterEligiblePackages(
    List<Package> packages,
    SubscriptionInfo currentSubscription,
  ) {
    if (!currentSubscription.isActive) return packages;

    // 获取当前订阅的月费用
    final currentMonthlyPrice = _getMonthlyPrice(
      currentSubscription.currentPackageId,
      packages,
    );

    if (currentMonthlyPrice == null) return packages;

    // 根据价格将套餐分为升级和降级选项
    return packages.where((package) {
      final packageMonthlyPrice = _calculateMonthlyPrice(package);
      return packageMonthlyPrice != currentMonthlyPrice;
    }).toList()
      ..sort((a, b) => _calculateMonthlyPrice(a).compareTo(_calculateMonthlyPrice(b)));
  }

  double _calculateMonthlyPrice(Package package) {
    final price = package.storeProduct.price;
    switch (package.packageType) {
      case PackageType.monthly:
        return price;
      case PackageType.annual:
        return price / 12;
      case PackageType.lifetime:
        return price / 24; // 假设生命周期为2年
      default:
        return price;
    }
  }

  double? _getMonthlyPrice(String? packageId, List<Package> packages) {
    if (packageId == null) return null;
    final currentPackage = packages.firstWhere(
      (p) => p.identifier == packageId,
      orElse: () => packages.first,
    );
    return _calculateMonthlyPrice(currentPackage);
  }

  bool _isUpgrade(Package package, double currentMonthlyPrice) {
    return _calculateMonthlyPrice(package) > currentMonthlyPrice;
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.subscription.changePlanTitle),
      ),
      body: Column(
        children: [
          // 说明文本
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              t.subscription.changePlanDescription,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

          // 套餐列表
          Expanded(
            child: _packages.when(
              data: (packages) => _buildPackagesList(packages, t),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${t.subscription.loadError}: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadPackages,
                      child: Text(t.general.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 底部按钮
          if (_selectedPackage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _handleChangePlan(context),
                child: Text(t.subscription.changePlanButton),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPackagesList(List<Package> packages, Translations t) {
    if (packages.isEmpty) {
      return Center(child: Text(t.subscription.noPlansAvailable));
    }

    final currentSubscription = ref.watch(subscriptionManagerProvider).value;
    if (currentSubscription == null) {
      return Center(child: Text(t.subscription.loadError));
    }

    final currentMonthlyPrice = _getMonthlyPrice(
      currentSubscription.currentPackageId,
      packages,
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        final isUpgrade = currentMonthlyPrice != null &&
            _isUpgrade(package, currentMonthlyPrice);

        return _buildPackageCard(
          package,
          isUpgrade,
          t,
        );
      },
    );
  }

  Widget _buildPackageCard(
    Package package,
    bool isUpgrade,
    Translations t,
  ) {
    final isSelected = package == _selectedPackage;
    final monthlyPrice = _calculateMonthlyPrice(package);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedPackage = package),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 套餐标签
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.storeProduct.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          package.storeProduct.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (isUpgrade)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.upgrade,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.subscription.upgrade,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // 价格信息
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.storeProduct.priceString,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getPeriodString(package.packageType, t),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${t.subscription.monthlyPrice}:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '\$${monthlyPrice.toStringAsFixed(2)}/${t.subscription.month}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 套餐特性列表
              ..._getFeaturesList(package, t).map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPeriodString(PackageType type, Translations t) {
    switch (type) {
      case PackageType.monthly:
        return t.subscription.perMonth;
      case PackageType.annual:
        return t.subscription.perYear;
      case PackageType.lifetime:
        return t.subscription.lifetime;
      default:
        return '';
    }
  }

  List<String> _getFeaturesList(Package package, Translations t) {
    // 这里可以根据包标识返回不同的特性列表
    if (package.packageType == PackageType.annual) {
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

  Future<void> _handleChangePlan(BuildContext context) async {
    if (_selectedPackage == null) return;

    final t = ref.read(translationsProvider);

    try {
      // 显示确认对话框
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.subscription.confirmChangeTitle),
          content: Text(t.subscription.confirmChangeMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.general.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.general.confirm),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // 显示加载指示器
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 执行计划变更
      await RevenueCatService.changePlan(_selectedPackage!);

      // 刷新订阅状态
      ref.refresh(subscriptionManagerProvider);

      if (context.mounted) {
        // 关闭加载指示器
        Navigator.pop(context);

        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.subscription.changeSuccess)),
        );

        // 返回上一页
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        // 关闭加载指示器
        Navigator.pop(context);

        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t.subscription.changeError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
