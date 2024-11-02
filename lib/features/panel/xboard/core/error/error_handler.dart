// lib/features/panel/xboard/core/error/error_handler.dart

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../analytics/analytics_service.dart';
import '../exceptions/auth_exceptions.dart';
import '../storage/xboard_cache_manager.dart';
import '../../models/payment_failure.dart';

final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler(
    analytics: ref.watch(analyticsProvider),
    cacheManager: ref.watch(cacheManagerProvider),
  );
});

class ErrorHandler {
  final AnalyticsService _analytics;
  final XboardCacheManager _cacheManager;
  static const String _errorCacheKey = 'error_logs';

  ErrorHandler({
    required AnalyticsService analytics,
    required XboardCacheManager cacheManager,
  })  : _analytics = analytics,
        _cacheManager = cacheManager;

  String handleError(dynamic error, [StackTrace? stackTrace]) {
    String errorMessage;

    if (error is AuthException) {
      errorMessage = _handleAuthError(error);
    } else if (error is PaymentFailure) {
      errorMessage = _handlePaymentFailure(error);
    } else {
      errorMessage = _handleGeneralError(error);
    }

    _logError(error, stackTrace, errorMessage);

    return errorMessage;
  }

  String _handleAuthError(AuthException error) {
    if (error is AuthenticationException) {
      return '认证失败: ${error.message}';
    } else if (error is RegistrationException) {
      return '注册失败: ${error.message}';
    } else if (error is VerificationException) {
      return '验证失败: ${error.message}';
    } else if (error is PasswordResetException) {
      return '重置密码失败: ${error.message}';
    } else if (error is TokenException) {
      return '令牌错误: ${error.message}';
    } else if (error is SessionExpiredException) {
      return '会话已过期，请重新登录';
    } else if (error is InvalidCredentialsException) {
      return '用户名或密码错误';
    } else if (error is EmailVerificationRequiredException) {
      return '请先验证邮箱';
    } else {
      return '认证过程出现错误: ${error.message}';
    }
  }

  String _handlePaymentFailure(PaymentFailure failure) {
    return failure.when(
      unexpected: (error, stackTrace) => '发生意外错误: $error',
      invalidAmount: () => '无效的支付金额',
      paymentCancelled: () => '支付已取消',
      paymentFailed: (message) => '支付失败: ${message ?? "未知错误"}',
      paymentTimeout: () => '支付超时',
      providerUnavailable: () => '支付服务不可用',
      networkError: () => '网络错误',
      invalidConfig: () => '支付配置无效',
      subscriptionNotFound: () => '未找到订阅信息',
      subscriptionExpired: () => '订阅已过期',
    );
  }

  String _handleGeneralError(dynamic error) {
    if (error is NetworkException) {
      return '网络错误: ${error.message}';
    } else if (error is ValidationException) {
      return '验证错误: ${error.message}';
    } else {
      return '发生错误: ${error.toString()}';
    }
  }

  Future<void> _logError(
    dynamic error,
    StackTrace? stackTrace,
    String errorMessage,
  ) async {
    // 记录错误到分析服务
    await _analytics.logError('app_error', {
      'error_type': error.runtimeType.toString(),
      'message': errorMessage,
      'stack_trace': stackTrace?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    });

    // 在开发环境打印错误
    if (kDebugMode) {
      print('Error: $errorMessage');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }

    // 缓存错误日志
    await _cacheErrorLog(error, stackTrace, errorMessage);
  }

  Future<void> _cacheErrorLog(
    dynamic error,
    StackTrace? stackTrace,
    String errorMessage,
  ) async {
    try {
      final errorLog = {
        'type': error.runtimeType.toString(),
        'message': errorMessage,
        'stack_trace': stackTrace?.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      final cachedLogs = await _cacheManager.getCachedData<List<dynamic>>(
        key: _errorCacheKey,
        fromJson: (json) => json as List<dynamic>,
      ) ?? [];

      // 限制缓存日志数量
      if (cachedLogs.length >= 100) {
        cachedLogs.removeAt(0);
      }

      cachedLogs.add(errorLog);

      await _cacheManager.cacheData(
        key: _errorCacheKey,
        data: cachedLogs,
        duration: const Duration(days: 7),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cache error log: $e');
      }
    }
  }

  Future<List<Map<String, dynamic>>> getErrorLogs() async {
    try {
      final logs = await _cacheManager.getCachedData<List<dynamic>>(
        key: _errorCacheKey,
        fromJson: (json) => json as List<dynamic>,
      );
      return logs?.cast<Map<String, dynamic>>() ?? [];
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get error logs: $e');
      }
      return [];
    }
  }

  Future<void> clearErrorLogs() async {
    try {
      await _cacheManager.clearCache(_errorCacheKey);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to clear error logs: $e');
      }
    }
  }
}

// 其他异常类型
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
  @override
  String toString() => message;
}