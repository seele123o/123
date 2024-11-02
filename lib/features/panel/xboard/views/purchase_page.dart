import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/panel/xboard/models/plan_model.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/purchase_viewmodel.dart';
import 'package:hiddify/features/panel/xboard/views/components/dialog/purchase_details_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/subscription/subscription_purchase_viewmodel.dart';


class PurchasePage extends ConsumerStatefulWidget {
  const PurchasePage({super.key});

  @override
  _PurchasePageState createState() => _PurchasePageState();
}

class _PurchasePageState extends ConsumerState<PurchasePage> {
  @override
  void initState() {
    super.initState();
    // 初始化时加载套餐数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(purchaseViewModelProvider).fetchPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);
    final viewModel = ref.watch(purchaseViewModelProvider);

    return Scaffold(
      appBar: NestedAppBar(
        title: Text(t.purchase.pageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.fetchPlans(),
            tooltip: t.general.refresh,
          ),
        ],
      ),
      body: _buildBody(context, viewModel, t),
    );
  }

  Widget _buildBody(BuildContext context, PurchaseViewModel viewModel, Translations t) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchPlans(),
              child: Text(t.general.retry),
            ),
          ],
        ),
      );
    }

    if (!viewModel.hasPlans) {
      return Center(
        child: Text(
          t.purchase.noPlansAvailable,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        // 搜索和排序控件
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: viewModel.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: t.purchase.searchPlaceholder,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<PlanSortType>(
                value: viewModel.sortType,
                onChanged: (value) {
                  if (value != null) viewModel.setSortType(value);
                },
                items: PlanSortType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(t.purchase.sortTypes(type.name)),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        // 套餐列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewModel.plans.length,
            itemBuilder: (context, index) {
              final plan = viewModel.plans[index];
              return _buildPlanCard(context, plan, t);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, Plan plan, Translations t) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => showPurchaseDialog(context, plan, t, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (plan.isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        t.purchase.popular,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              if (plan.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  plan.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              if (plan.features.isNotEmpty) ...[
                Text(
                  t.purchase.features,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...plan.features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(feature)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (plan.lowestMonthlyPrice != null)
                    Text(
                      '${t.purchase.startingAt} ${t.pricing.currency.cny}${plan.lowestMonthlyPrice!.toStringAsFixed(2)}/${t.purchase.month}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () => showPurchaseDialog(context, plan, t, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(t.purchase.subscribe),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}