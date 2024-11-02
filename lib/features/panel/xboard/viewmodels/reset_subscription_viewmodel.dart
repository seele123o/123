import 'dart:async';
import 'package:flutter/material.dart';
import '../services/http_service/subscription_service.dart';
import '../core/error/error_handler.dart';
import '../core/notifications/notification_service.dart';
import '../core/analytics/analytics_service.dart';

class ResetSubscriptionViewModel extends ChangeNotifier {
  final SubscriptionService _subscriptionService;
  final ErrorHandler _errorHandler;
  final AnalyticsService _analytics;
  final NotificationService _notifications;

  // 基础状态
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _error;

  // 冷却时间控制
  final Duration _cooldown = const Duration(minutes: 5);
  DateTime? _lastResetTime;
  Timer? _cooldownTimer;

  // 重置计数
  int _resetCount = 0;
  static const int _maxResetPerDay = 3;
  DateTime? _resetCountDate;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get error => _error;
  bool get canReset => _isResetAllowed && !isInCooldown;
  bool get isInCooldown => _lastResetTime != null && DateTime.now().difference(_lastResetTime!) < _cooldown;

  Duration get remainingCooldown => _lastResetTime != null ? _cooldown - DateTime.now().difference(_lastResetTime!) : Duration.zero;

  int get remainingResets => _maxResetPerDay - _resetCount;

  ResetSubscriptionViewModel({
    required SubscriptionService subscriptionService,
    required ErrorHandler errorHandler,
    required AnalyticsService analytics,
    required NotificationService notifications,
  })  : _subscriptionService = subscriptionService,
        _errorHandler = errorHandler,
        _analytics = analytics,
        _notifications = notifications {
    _initResetCount();
  }

  void _initResetCount() {
    final now = DateTime.now();
    if (_resetCountDate?.day != now.day) {
      _resetCount = 0;
      _resetCountDate = now;
    }
  }

  bool get _isResetAllowed {
    _initResetCount();
    return _resetCount < _maxResetPerDay;
  }

  Future<void> resetSubscription() async {
    if (!canReset) {
      _notifications.show(
        title: '无法重置订阅',
        body: isInCooldown ? '请等待${formatDuration(remainingCooldown)}后再试' : '今日重置次数已达上限',
        type: NotificationType.warning,
      );
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _subscriptionService.resetSubscription();

      // 更新状态
      _isSuccess = true;
      _lastResetTime = DateTime.now();
      _resetCount++;
      _startCooldownTimer();

      // 记录分析数据
      _analytics.logEvent('subscription_reset', {
        'reset_count': _resetCount,
        'cooldown_started': _lastResetTime?.toIso8601String(),
      });

      _notifications.show(
        title: '重置成功',
        body: '订阅已成功重置',
        type: NotificationType.success,
      );
    } catch (e) {
      _error = _errorHandler.handleError(e);
      _isSuccess = false;

      _notifications.show(
        title: '重置失败',
        body: _error ?? '未知错误',
        type: NotificationType.error,
      );

      _analytics.logError('subscription_reset_failed', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!isInCooldown) {
          _cooldownTimer?.cancel();
        }
        notifyListeners();
      },
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
