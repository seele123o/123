// lib/features/panel/xboard/viewmodels/user_info_viewmodel.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hiddify/features/panel/xboard/providers/index.dart';
import '../models/user_info_model.dart';

// 定义 UserInfoState
class UserInfoState {
  final UserInfo? userInfo;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final Timer? autoRefreshTimer;
  final Timer? expiryCheckTimer;

  const UserInfoState({
    this.userInfo,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.autoRefreshTimer,
    this.expiryCheckTimer,
  });

  UserInfoState copyWith({
    UserInfo? userInfo,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    Timer? autoRefreshTimer,
    Timer? expiryCheckTimer,
  }) {
    return UserInfoState(
      userInfo: userInfo ?? this.userInfo,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,  // 允许设置为 null
      autoRefreshTimer: autoRefreshTimer ?? this.autoRefreshTimer,
      expiryCheckTimer: expiryCheckTimer ?? this.expiryCheckTimer,
    );
  }
}

class UserInfoViewModel extends StateNotifier<UserInfoState> {
  final UserService _userService;
  final XboardCacheManager _cacheManager;
  final ErrorHandler _errorHandler;
  final AnalyticsService _analytics;

  static const Duration _refreshInterval = Duration(minutes: 5);
  static const Duration _expiryCheckInterval = Duration(minutes: 30);
  static const Duration _dataWarningThreshold = Duration(days: 7);
  static const double _usageWarningThreshold = 0.8;

  UserInfoViewModel({
    required UserService userService,
    required XboardCacheManager cacheManager,
    required ErrorHandler errorHandler,
    required AnalyticsService analytics,
  })  : _userService = userService,
        _cacheManager = cacheManager,
        _errorHandler = errorHandler,
        _analytics = analytics,
        super(const UserInfoState()) {
    _initializeTimers();
    _loadInitialData();
  }

  void _initializeTimers() {
    final autoRefreshTimer = Timer.periodic(_refreshInterval, (_) => _autoRefresh());
    final expiryCheckTimer = Timer.periodic(_expiryCheckInterval, (_) => _checkSubscriptionStatus());

    state = state.copyWith(
      autoRefreshTimer: autoRefreshTimer,
      expiryCheckTimer: expiryCheckTimer,
    );
  }

  Future<void> _loadInitialData() async {
    try {
      final cachedInfo = await _cacheManager.getCachedData<UserInfo>(
        key: 'user_info',
        fromJson: UserInfo.fromJson,
      );

      if (cachedInfo != null) {
        state = state.copyWith(userInfo: cachedInfo);
      }

      await refreshUserInfo(showLoadingIndicator: !cachedInfo?.isCached ?? true);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> refreshUserInfo({bool showLoadingIndicator = true}) async {
    if (state.isRefreshing) return;

    if (showLoadingIndicator) {
      state = state.copyWith(isLoading: true);
    }

    state = state.copyWith(isRefreshing: true);
    try {
      final userInfo = await _userService.fetchUserInfo();
      state = state.copyWith(
        userInfo: userInfo,
        error: null,
      );

      // 检查并发出警告
      _checkDataUsage();
      _checkExpiryStatus();

      // 记录分析数据
      _analytics.logEvent('user_info_refreshed', {
        'has_subscription': userInfo?.hasActiveSubscription,
        'data_usage': userInfo?.calculateDataUsagePercentage(),
      });
    } catch (e) {
      _handleError(e);
    } finally {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
      );
    }
  }

  void _checkDataUsage() {
    if (state.userInfo == null) return;
    final usagePercentage = state.userInfo!.calculateDataUsagePercentage();

    if (usagePercentage >= _usageWarningThreshold) {
      _notifyDataUsageWarning(usagePercentage);
    }
  }

  void _checkExpiryStatus() {
    final userInfo = state.userInfo;
    if (userInfo?.subscriptionEndDate == null) return;

    final endDate = DateTime.fromMillisecondsSinceEpoch(userInfo!.subscriptionEndDate!);
    final remaining = endDate.difference(DateTime.now());

    if (remaining <= _dataWarningThreshold && remaining.isPositive) {
      _notifyExpiryWarning(remaining);
    }
  }

  void _notifyDataUsageWarning(double usagePercentage) {
    _analytics.logEvent('data_usage_warning', {
      'usage_percentage': usagePercentage,
    });
    // TODO: 在这里实现具体的警告通知逻辑
  }

  void _notifyExpiryWarning(Duration remaining) {
    _analytics.logEvent('subscription_expiry_warning', {
      'remaining_days': remaining.inDays,
    });
    // TODO: 在这里实现具体的过期警告通知逻辑
  }

  Future<void> _autoRefresh() async {
    await refreshUserInfo(showLoadingIndicator: false);
  }

  void _handleError(dynamic error) {
    final errorMessage = _errorHandler.handleError(error);
    _analytics.logError('user_info_error', error);
    state = state.copyWith(error: errorMessage);
  }

  @override
  void dispose() {
    state.autoRefreshTimer?.cancel();
    state.expiryCheckTimer?.cancel();
    super.dispose();
  }

  // 工具方法
  String formatDataUsage(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }
}

// Provider 定义
final userInfoViewModelProvider = StateNotifierProvider<UserInfoViewModel, UserInfoState>((ref) {
  return UserInfoViewModel(
    userService: ref.watch(userServiceProvider),
    cacheManager: ref.watch(cacheManagerProvider),
    errorHandler: ref.watch(errorHandlerProvider),
    analytics: ref.watch(analyticsProvider),
  );
});