// lib/features/panel/xboard/core/analytics/analytics_service.dart

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../storage/xboard_cache_manager.dart';

final analyticsProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(
    enableAnalytics: !kDebugMode, // 生产环境开启分析
    cacheManager: ref.watch(cacheManagerProvider),
  );
});

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic>? parameters;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    this.parameters,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'parameters': parameters,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      name: json['name'] as String,
      parameters: json['parameters'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class AnalyticsService {
  final bool enableAnalytics;
  final XboardCacheManager _cacheManager;

  AnalyticsService({
    this.enableAnalytics = true,
    required XboardCacheManager cacheManager,
  }) : _cacheManager = cacheManager;

  // 用户会话相关事件
  Future<void> logSessionStart({required String userId}) async {
    await logEvent('session_start', {'user_id': userId});
  }

  Future<void> logSessionEnd({required String userId}) async {
    await logEvent('session_end', {'user_id': userId});
  }

  // 用户身份验证事件
  Future<void> logAuthentication({
    required String userId,
    required String method,
    required bool success,
    String? errorMessage,
  }) async {
    await logEvent('authentication', {
      'user_id': userId,
      'method': method,
      'success': success,
      if (errorMessage != null) 'error': errorMessage,
    });
  }

  // 订阅相关事件
  Future<void> logSubscriptionEvent({
    required String userId,
    required String action,
    required String planId,
    double? amount,
    String? currency,
    String? provider,
  }) async {
    await logEvent('subscription_event', {
      'user_id': userId,
      'action': action,
      'plan_id': planId,
      if (amount != null) 'amount': amount,
      if (currency != null) 'currency': currency,
      if (provider != null) 'provider': provider,
    });
  }

  // 缓存性能跟踪
  void trackCacheOperation({
    required String operation,
    required String key,
    required bool success,
    int? sizeBytes,
    Duration? duration,
  }) {
    CacheAnalytics.trackOperation(
      operation: operation,
      key: key,
      success: success,
      sizeBytes: sizeBytes,
      duration: duration,
    );
  }

  // 基础事件记录
  Future<void> logEvent(String eventName, [Map<String, dynamic>? parameters]) async {
    if (!enableAnalytics) return;

    try {
      final event = AnalyticsEvent(
        name: eventName,
        parameters: parameters,
      );

      // 使用 CacheAnalytics 记录分析事件
      CacheAnalytics.trackEvent(event.toJson());

      if (kDebugMode) {
        print('Analytics Event: ${event.name}');
        if (event.parameters != null) {
          print('Parameters: ${event.parameters}');
        }
      }

      // TODO: 实现实际的分析事件上报逻辑
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log analytics event: $e');
      }
    }
  }

  // 错误跟踪
  Future<void> logError(String errorType, dynamic error) async {
    if (!enableAnalytics) return;

    try {
      final errorEvent = AnalyticsEvent(
        name: 'error',
        parameters: {
          'type': errorType,
          'message': error.toString(),
          'stackTrace': StackTrace.current.toString(),
        },
      );

      CacheAnalytics.trackError(errorEvent.toJson());

      if (kDebugMode) {
        print('Analytics Error: $errorType');
        print('Error Details: $error');
      }

      // TODO: 实现实际的错误上报逻辑
    } catch (e) {
      if (kDebugMode) {
        print('Failed to log error event: $e');
      }
    }
  }

  // 性能跟踪
  Future<void> logPerformance({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? metadata,
  }) async {
    await logEvent('performance', {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      if (metadata != null) ...metadata,
    });
  }

  // 功能使用跟踪
  Future<void> logFeatureUsage({
    required String userId,
    required String feature,
    Map<String, dynamic>? parameters,
  }) async {
    await logEvent('feature_usage', {
      'user_id': userId,
      'feature': feature,
      if (parameters != null) ...parameters,
    });
  }

  // 用户操作跟踪
  Future<void> logUserAction({
    required String userId,
    required String action,
    required String target,
    Map<String, dynamic>? metadata,
  }) async {
    await logEvent('user_action', {
      'user_id': userId,
      'action': action,
      'target': target,
      if (metadata != null) ...metadata,
    });
  }
}