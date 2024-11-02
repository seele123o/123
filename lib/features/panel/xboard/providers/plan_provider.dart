// lib/features/panel/xboard/providers/plans_provider.dart

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/plan_model.dart';
import '../services/http_service/plan_service.dart';
import '../core/storage/xboard_cache_manager.dart';
import './services_provider.dart';

/// Plan Service Provider
final planServiceProvider = Provider((ref) => PlanService());

/// Plan Providers
final planProvider = FutureProvider.family<Plan?, int>((ref, planId) async {
  final cacheManager = ref.watch(cacheManagerProvider);
  final cacheKey = 'plan_$planId';

  try {
    // 尝试从缓存获取
    final cachedPlan = await cacheManager.getCachedData<Plan>(
      key: cacheKey,
      fromJson: (json) => Plan.fromJson(json),
    );

    if (cachedPlan != null) {
      return cachedPlan;
    }

    // 从服务器获取
    final planService = ref.watch(planServiceProvider);
    final plans = await planService.fetchPlanData();
    final plan = plans.firstWhere(
      (p) => p.id == planId,
      orElse: () => throw Exception('Plan not found'),
    );

    // 缓存计划数据
    await cacheManager.cacheData(
      key: cacheKey,
      data: plan,
      duration: const Duration(hours: 12),
    );

    return plan;
  } catch (e) {
    ref.read(errorHandlerProvider).handleError(e);
    rethrow;
  }
});

final plansProvider = FutureProvider<List<Plan>>((ref) async {
  final cacheManager = ref.watch(cacheManagerProvider);
  const cacheKey = 'all_plans';

  try {
    // 尝试从缓存获取
    final cachedPlans = await cacheManager.getCachedData<List<Plan>>(
      key: cacheKey,
      fromJson: (json) => (json['plans'] as List).map((plan) => Plan.fromJson(plan)).toList(),
    );

    if (cachedPlans != null) {
      return cachedPlans;
    }

    // 从服务器获取
    final planService = ref.watch(planServiceProvider);
    final plans = await planService.fetchPlanData();

    // 缓存计划列表
    await cacheManager.cacheData(
      key: cacheKey,
      data: {'plans': plans},
      duration: const Duration(hours: 12),
    );

    return plans;
  } catch (e) {
    ref.read(errorHandlerProvider).handleError(e);
    rethrow;
  }
});

/// Plan Search and Sort Providers
final planSearchProvider = StateProvider<String>((ref) => '');

final planSortTypeProvider = StateProvider<PlanSortType>((ref) => PlanSortType.popularity);

/// Filtered Plans Provider
final filteredPlansProvider = Provider<AsyncValue<List<Plan>>>((ref) {
  final plansAsync = ref.watch(plansProvider);
  final searchQuery = ref.watch(planSearchProvider);

  return plansAsync.whenData((plans) {
    if (searchQuery.isEmpty) return plans;

    return plans.where((plan) {
      final searchLower = searchQuery.toLowerCase();
      return plan.name.toLowerCase().contains(searchLower) || (plan.description?.toLowerCase().contains(searchLower) ?? false);
    }).toList();
  });
});

/// Sorted Plans Provider
final sortedPlansProvider = Provider<AsyncValue<List<Plan>>>((ref) {
  final filteredPlansAsync = ref.watch(filteredPlansProvider);
  final sortType = ref.watch(planSortTypeProvider);

  return filteredPlansAsync.whenData((plans) {
    final sortedPlans = List<Plan>.from(plans);
    switch (sortType) {
      case PlanSortType.nameAsc:
        sortedPlans.sort((a, b) => a.name.compareTo(b.name));
        break;
      case PlanSortType.nameDesc:
        sortedPlans.sort((a, b) => b.name.compareTo(a.name));
        break;
      case PlanSortType.priceAsc:
        sortedPlans.sort((a, b) => (a.lowestMonthlyPrice ?? double.infinity).compareTo(b.lowestMonthlyPrice ?? double.infinity));
        break;
      case PlanSortType.priceDesc:
        sortedPlans.sort((a, b) => (b.lowestMonthlyPrice ?? double.infinity).compareTo(a.lowestMonthlyPrice ?? double.infinity));
        break;
      case PlanSortType.popularity:
        sortedPlans.sort((a, b) => b.isPopular ? 1 : -1);
        break;
    }
    return sortedPlans;
  });
});
