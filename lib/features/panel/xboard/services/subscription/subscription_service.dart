import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/http_client/dio_http_client.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/utils/exception_handler.dart';
import 'package:hiddify/features/panel/xboard/models/subscription_model.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService with ExceptionHandler, InfraLogger {
  final DioHttpClient _httpClient;

  SubscriptionService({required DioHttpClient httpClient})
    : _httpClient = httpClient;

  // 获取订阅信息
  TaskEither<PaymentFailure, SubscriptionModel> getSubscription(String accessToken) {
    return TaskEither.tryCatch(
      () async {
        final response = await _httpClient.get(
          "/api/v1/user/subscription",
          options: Options(headers: {'Authorization': accessToken}),
        );

        if (response.statusCode != 200 || response.data == null) {
          loggy.warning("获取订阅信息失败");
          throw const PaymentFailure.subscriptionNotFound();
        }

        return SubscriptionModel.fromJson(response.data['data']);
      },
      (error, stackTrace) {
        loggy.error("获取订阅信息出错", error, stackTrace);
        return PaymentFailure.unexpected(error, stackTrace);
      },
    );
  }

  // 监听订阅状态变化
  Stream<Either<PaymentFailure, SubscriptionModel>> watchSubscription(String accessToken) {
    return Stream.periodic(const Duration(seconds: 30))
      .startWith(0)
      .asyncMap((_) => getSubscription(accessToken).run());
  }

  // 获取账单历史
  TaskEither<PaymentFailure, List<BillingHistory>> getBillingHistory(String accessToken) {
    return TaskEither.tryCatch(
      () async {
        final response = await _httpClient.get(
          "/api/v1/user/billing/history",
          options: Options(headers: {'Authorization': accessToken}),
        );

        if (response.statusCode != 200 || response.data == null) {
          loggy.warning("获取账单历史失败");
          throw const PaymentFailure.unexpected();
        }

        final List<dynamic> historyData = response.data['data'];
        return historyData
          .map((item) => BillingHistory.fromJson(item))
          .toList();
      },
      (error, stackTrace) {
        loggy.error("获取账单历史出错", error, stackTrace);
        return PaymentFailure.unexpected(error, stackTrace);
      },
    );
  }

  // 修改自动续费设置
  TaskEither<PaymentFailure, Unit> setAutoRenewal(String accessToken, bool enabled) {
    return TaskEither.tryCatch(
      () async {
        final response = await _httpClient.post(
          "/api/v1/user/subscription/auto-renew",
          data: {'enabled': enabled},
          options: Options(headers: {'Authorization': accessToken}),
        );

        if (response.statusCode != 200) {
          loggy.warning("修改自动续费设置失败");
          throw const PaymentFailure.unexpected();
        }

        return unit;
      },
      (error, stackTrace) {
        loggy.error("修改自动续费设置出错", error, stackTrace);
        return PaymentFailure.unexpected(error, stackTrace);
      },
    );
  }

  // 取消订阅
  TaskEither<PaymentFailure, Unit> cancelSubscription(String accessToken) {
    return TaskEither.tryCatch(
      () async {
        final response = await _httpClient.post(
          "/api/v1/user/subscription/cancel",
          options: Options(headers: {'Authorization': accessToken}),
        );

        if (response.statusCode != 200) {
          loggy.warning("取消订阅失败");
          throw const PaymentFailure.unexpected();
        }

        return unit;
      },
      (error, stackTrace) {
        loggy.error("取消订阅出错", error, stackTrace);
        return PaymentFailure.unexpected(error, stackTrace);
      },
    );
  }

  // 重置订阅
  TaskEither<PaymentFailure, Unit> resetSubscription(String accessToken) {
    return TaskEither.tryCatch(
      () async {
        final response = await _httpClient.post(
          "/api/v1/user/subscription/reset",
          options: Options(headers: {'Authorization': accessToken}),
        );

        if (response.statusCode != 200) {
          loggy.warning("重置订阅失败");
          throw const PaymentFailure.unexpected();
        }

        return unit;
      },
      (error, stackTrace) {
        loggy.error("重置订阅出错", error, stackTrace);
        return PaymentFailure.unexpected(error, stackTrace);
      },
    );
  }

  // 恢复购买
  TaskEither<PaymentFailure, Unit> restorePurchases(String accessToken) {
    return TaskEither.tryCatch(
      () async {
        try {
          final customerInfo = await Purchases.restorePurchases();

          // 同步RevenueCat购买记录到服务器
          await _httpClient.post(
            "/api/v1/user/subscription/restore",
            data: {
              'customer_info': customerInfo.originalJson,
            },
            options: Options(headers: {'Authorization': accessToken}),
          );

          return unit;
        } catch (e) {
          loggy.warning("恢复购买失败", e);
          throw const PaymentFailure.unexpected();
        }
      },
      (error, stackTrace) {
        loggy.error("恢复购买出错", error, stackTrace);
        return PaymentFailure.unexpected(error, stackTrace);
      },
    );
  }

  // 同步订阅状态
  TaskEither<PaymentFailure, Unit> syncSubscriptionStatus(String accessToken) {
    return TaskEither.tryCatch(
      () async {
        try {
          final customerInfo = await Purchases.getCustomerInfo();

          await _httpClient.post(
            "/api/v1/user/subscription/sync",
            data: {
              'customer_info': customerInfo.originalJson,
            },
            options: Options(headers: {'Authorization': accessToken}),
          );

          return unit;
        } catch (e) {
          loggy.warning("同步订阅状态失败", e);
          throw const PaymentFailure.unexpected();
        }
      },
      (error, stackTrace) {
        loggy.error("同步订阅状态出错", error, stackTrace);
        return PaymentFailure.unexpected(error, stackTrace);
      },
    );
  }

  // 验证订阅状态
  TaskEither<PaymentFailure, bool> validateSubscription(String accessToken) {
    return TaskEither.tryCatch(
      () async {
        final response = await _httpClient.get(
          "/api/v1/user/subscription/validate",
          options: Options(headers: {'Authorization': accessToken}),
        );

        if (response.statusCode != 200) {
          loggy.warning("验证订阅失败");
          throw const PaymentFailure.unexpected();
        }

        return response.data['data']['is_valid'] as bool;
      },
      (error, stackTrace) {
        loggy.error("验证订阅出错", error, stackTrace);
        return PaymentFailure.unexpected(error, stackTrace);
      },
    );
  }

  // 更新订阅信息
  TaskEither<PaymentFailure, Unit> updateSubscriptionInfo(
    String accessToken,
    Map<String, dynamic> info,
  ) {
    return TaskEither.tryCatch(
      () async {
        final response = await _httpClient.post(
          "/api/v1/user/subscription/update",
          data: info,
          options: Options(headers: {'Authorization': accessToken}),
        );

        if (response.statusCode != 200) {
          loggy.warning("更新订阅信息失败");
          throw const PaymentFailure.unexpected();
        }

        return unit;
      },
      (error, stackTrace) {
        loggy.error("更新订阅信息出错", error, stackTrace);
        return PaymentFailure.unexpected(error, stackTrace);
      },
    );
  }
}