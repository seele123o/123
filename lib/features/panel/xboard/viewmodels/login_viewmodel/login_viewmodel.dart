// lib/features/panel/xboard/viewmodels/login_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hiddify/features/panel/xboard/providers/index.dart';

// 定义状态模型
class LoginState {
  final bool isLoading;
  final bool isRememberMe;
  final String? error;
  final String? username;
  final String? password;

  const LoginState({
    this.isLoading = false,
    this.isRememberMe = false,
    this.error,
    this.username,
    this.password,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isRememberMe,
    String? error,
    String? username,
    String? password,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isRememberMe: isRememberMe ?? this.isRememberMe,
      error: error,  // 允许设置为 null
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}

class LoginViewModel extends StateNotifier<LoginState> {
  final AuthService _authService;
  final HttpService _httpService;
  final ErrorHandler _errorHandler;
  final AnalyticsService _analytics;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  LoginViewModel({
    required AuthService authService,
    required HttpService httpService,
    required ErrorHandler errorHandler,
    required AnalyticsService analytics,
  })  : _authService = authService,
        _httpService = httpService,
        _errorHandler = errorHandler,
        _analytics = analytics,
        super(const LoginState()) {
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString('saved_username');
      final savedPassword = prefs.getString('saved_password');
      final rememberMe = prefs.getBool('remember_me') ?? false;

      if (savedUsername != null && savedPassword != null && rememberMe) {
        usernameController.text = savedUsername;
        passwordController.text = savedPassword;
        state = state.copyWith(
          isRememberMe: true,
          username: savedUsername,
          password: savedPassword,
        );
      }
    } catch (e) {
      _analytics.logError('load_credentials_failed', e);
    }
  }

  Future<void> _saveCredentials() async {
    try {
      if (state.isRememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_username', usernameController.text);
        await prefs.setString('saved_password', passwordController.text);
        await prefs.setBool('remember_me', true);
      }
    } catch (e) {
      _analytics.logError('save_credentials_failed', e);
    }
  }

  void toggleRememberMe(bool value) {
    state = state.copyWith(isRememberMe: value);
  }

  Future<void> login(BuildContext context, WidgetRef ref) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      if (kDebugMode) {
        print('正在检查服务器连接...');
      }

      await _httpService.initialize();

      if (kDebugMode) {
        print('服务器连接正常，开始登录...');
      }

      final result = await _authService.login(
        usernameController.text,
        passwordController.text,
      );

      await _handleLoginSuccess(result, context, ref);

    } catch (e) {
      final errorMessage = e is ConnectionException
          ? '无法连接到服务器，请检查网络连接'
          : '登录失败：${e.toString()}';

      state = state.copyWith(error: errorMessage);
      _analytics.logError('login_failed', e);

      if (kDebugMode) {
        print('登录错误: $errorMessage');
      }
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _handleLoginSuccess(AuthResult result, BuildContext context, WidgetRef ref) async {
    try {
      // 存储认证令牌
      await _storeTokens(result);

      // 保存凭证（如果需要）
      if (state.isRememberMe) {
        await _saveCredentials();
      }

      // 更新认证状态
      ref.read(authProvider.notifier).state = true;

      // 记录登录事件
      _analytics.logEvent('login_success', {
        'username': usernameController.text,
      });

    } catch (e) {
      _analytics.logError('post_login_process_failed', e);
      rethrow;
    }
  }

  Future<void> _storeTokens(AuthResult result) async {
    await storeToken(result.token);

    if (result.paymentTokens != null) {
      if (result.paymentTokens!['stripe_token'] != null) {
        await storeStripeToken(result.paymentTokens!['stripe_token']);
      }
      if (result.paymentTokens!['revenuecat_token'] != null) {
        await storeRevenueCatToken(result.paymentTokens!['revenuecat_token']);
      }
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> cleanup() async {
    await clearAllTokens();
    _analytics.logEvent('logout');
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

// Provider 定义
final loginViewModelProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  return LoginViewModel(
    authService: ref.watch(authServiceProvider),
    httpService: ref.watch(httpServiceProvider),
    errorHandler: ref.watch(errorHandlerProvider),
    analytics: ref.watch(analyticsProvider),
  );
});