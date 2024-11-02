// services/plan_service.dart
import 'package:hiddify/features/panel/xboard/models/plan_model.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/http_service.dart';
import 'package:hiddify/features/panel/xboard/core/storage/xboard_cache_manager.dart';
import 'package:hiddify/features/panel/xboard/core/storage/xboard_storage_config.dart';

class PlanService {
  final HttpService _httpService = HttpService();
  final XboardCacheManager _cacheManager = XboardCacheManager();

  // 获取所有计划
  Future<List<Plan>> fetchPlanData(String accessToken) async {
    try {
      // 尝试从缓存获取
      final cachedPlans = await _cacheManager.getCachedData<List<Plan>>(
        key: XboardStorageConfig.plansKey,
        fromJson: (json) => (json['plans'] as List)
            .cast<Map<String, dynamic>>()
            .map((plan) => Plan.fromJson(plan))
            .toList(),
      );

      if (cachedPlans != null) {
        return cachedPlans;
      }

      // 从服务器获取
      final result = await _httpService.getRequest(
        "/api/v1/user/plan/fetch",
        headers: {'Authorization': accessToken},
      );

      final plans = (result["data"] as List)
          .cast<Map<String, dynamic>>()
          .map((json) => Plan.fromJson(json))
          .toList();

      // 缓存结果
      await _cacheManager.cacheData(
        key: XboardStorageConfig.plansKey,
        data: {'plans': plans},
        duration: XboardStorageConfig.plansCacheDuration,
      );

      return plans;
    } catch (e) {
      throw Exception('Failed to fetch plans: $e');
    }
  }

  // 获取特定计划详情
  Future<Plan> fetchPlanDetail(String accessToken, int planId) async {
    try {
      final result = await _httpService.getRequest(
        "/api/v1/user/plan/detail/$planId",
        headers: {'Authorization': accessToken},
      );

      if (result["status"] == "success") {
        return Plan.fromJson(result["data"]);
      } else {
        throw Exception(result["message"] ?? 'Failed to fetch plan detail');
      }
    } catch (e) {
      throw Exception('Failed to fetch plan detail: $e');
    }
  }

  // 获取计划的支付配置
  Future<PlanPaymentInfo> fetchPlanPaymentInfo(
    String accessToken, 
    int planId,
    PlanPeriod period,
  ) async {
    try {
      final result = await _httpService.getRequest(
        "/api/v1/user/plan/payment_info",
        queryParameters: {
          'plan_id': planId.toString(),
          'period': period.toString(),
        },
        headers: {'Authorization': accessToken},
      );

      if (result["status"] == "success") {
        return PlanPaymentInfo.fromJson(result["data"]);
      } else {
        throw Exception(result["message"] ?? 'Failed to fetch payment info');
      }
    } catch (e) {
      throw Exception('Failed to fetch payment info: $e');
    }
  }

  // 检查计划价格
  Future<PlanPricing> validatePlanPricing(
    String accessToken, 
    int planId,
  ) async {
    try {
      final result = await _httpService.getRequest(
        "/api/v1/user/plan/validate_pricing/$planId",
        headers: {'Authorization': accessToken},
      );

      if (result["status"] == "success") {
        return PlanPricing.fromJson(result["data"]);
      } else {
        throw Exception(result["message"] ?? 'Failed to validate plan pricing');
      }
    } catch (e) {
      throw Exception('Failed to validate plan pricing: $e');
    }
  }

  // 获取可用的支付方式
  Future<List<PaymentProvider>> getAvailablePaymentMethods(
    String accessToken,
    int planId,
    PlanPeriod period,
  ) async {
    try {
      final result = await _httpService.getRequest(
        "/api/v1/user/plan/payment_methods",
        queryParameters: {
          'plan_id': planId.toString(),
          'period': period.toString(),
        },
        headers: {'Authorization': accessToken},
      );

      if (result["status"] == "success") {
        return (result["data"] as List)
            .map((method) => PaymentProvider.fromString(method))
            .toList();
      } else {
        throw Exception(result["message"] ?? 'Failed to get payment methods');
      }
    } catch (e) {
      throw Exception('Failed to get payment methods: $e');
    }
  }

  // 刷新计划缓存
  Future<void> refreshPlansCache(String accessToken) async {
    await _cacheManager.clearCache(XboardStorageConfig.plansKey);
    await fetchPlanData(accessToken);
  }

  // 获取推荐计划
  Future<Plan?> getRecommendedPlan(String accessToken) async {
    final plans = await fetchPlanData(accessToken);
    return plans.firstWhere(
      (plan) => plan.isPopular,
      orElse: () => plans.first,
    );
  }

  // 获取计划比较
  Future<Map<String, dynamic>> comparePlans(
    String accessToken,
    List<int> planIds,
  ) async {
    try {
      final result = await _httpService.postRequest(
        "/api/v1/user/plan/compare",
        {'plan_ids': planIds},
        headers: {'Authorization': accessToken},
      );

      if (result["status"] == "success") {
        return result["data"];
      } else {
        throw Exception(result["message"] ?? 'Failed to compare plans');
      }
    } catch (e) {
      throw Exception('Failed to compare plans: $e');
    }
  }
}

// 扩展方法
extension PlanListExtension on List<Plan> {
  // 按价格排序
  List<Plan> sortByPrice(PlanPeriod period) {
    return [...this]..sort((a, b) {
        final priceA = a.getPriceForPeriod(period) ?? double.infinity;
        final priceB = b.getPriceForPeriod(period) ?? double.infinity;
        return priceA.compareTo(priceB);
      });
  }

  // 按月均价格排序
  List<Plan> sortByMonthlyPrice(PlanPeriod period) {
    return [...this]..sort((a, b) {
        final priceA = a.getMonthlyAveragePrice(period) ?? double.infinity;
        final priceB = b.getMonthlyAveragePrice(period) ?? double.infinity;
        return priceA.compareTo(priceB);
      });
  }

  // 获取特定价格范围的计划
  List<Plan> inPriceRange(double min, double max, PlanPeriod period) {
    return where((plan) {
      final price = plan.getPriceForPeriod(period);
      return price != null && price >= min && price <= max;
    }).toList();
  }

  // 获取支持特定支付方式的计划
  List<Plan> supportingPaymentProvider(PaymentProvider provider) {
    return where((plan) => plan.supportsPaymentProvider(provider)).toList();
  }
}
