// lib/features/panel/xboard/services/http_service/auth_service.dart
// 第三方包导入
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 项目内导入统一使用 providers/index.dart
import 'package:hiddify/features/panel/xboard/providers/index.dart';

// 项目内其他必需的直接导入
import '../utils/storage/token_storage.dart';
import '../models/auth_result.dart';

// lib/features/panel/xboard/services/http_service/auth_service.dart

class AuthService {
  final HttpService _httpService;
  final XboardCacheManager _cacheManager;
  final AnalyticsService _analytics;
  final ErrorHandler _errorHandler;

  AuthService({
    required HttpService httpService,
    required XboardCacheManager cacheManager,
    required AnalyticsService analytics,
    required ErrorHandler errorHandler,
  })  : _httpService = httpService,
        _cacheManager = cacheManager,
        _analytics = analytics,
        _errorHandler = errorHandler;

  Future<AuthResult> login(String email, String password) async {
    try {
      _analytics.logEvent('login_attempt', {'email': email});

      final result = await _httpService.postRequest(
        "/api/v1/user/login",
        {
          'email': email,
          'password': password,
        },
      );

      if (result['status'] != 'success') {
        _analytics.logError('login_failed', result['message']);
        throw AuthenticationException(result['message'] ?? 'Login failed');
      }

      final authData = result['data'];

      // 缓存用户信息
      await _cacheManager.cacheData(
        key: 'user_info',
        data: authData['user'],
        duration: const Duration(hours: 24),
      );

      _analytics.logEvent('login_success', {'email': email});

      return AuthResult(
        token: authData['token'],
        user: authData['user'],
        paymentTokens: authData['payment_tokens'],
      );
    } catch (e) {
      final errorMsg = _errorHandler.handleError(e);
      _analytics.logError('login_error', e);
      throw AuthenticationException(errorMsg);
    }
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String emailCode,
    String? inviteCode,
  }) async {
    try {
      _analytics.logEvent('register_attempt', {'email': email});

      final data = {
        'email': email,
        'password': password,
        'email_code': emailCode,
      };

      if (inviteCode != null) {
        data['invite_code'] = inviteCode;
      }

      final result = await _httpService.postRequest(
        "/api/v1/user/register",
        data,
      );

      if (result['status'] != 'success') {
        _analytics.logError('registration_failed', result['message']);
        throw RegistrationException(result['message'] ?? 'Registration failed');
      }

      final authData = result['data'];

      // 缓存用户信息
      await _cacheManager.cacheData(
        key: 'user_info',
        data: authData['user'],
        duration: const Duration(hours: 24),
      );

      _analytics.logEvent('register_success', {'email': email});

      return AuthResult(
        token: authData['token'],
        user: authData['user'],
        paymentTokens: authData['payment_tokens'],
      );
    } catch (e) {
      final errorMsg = _errorHandler.handleError(e);
      _analytics.logError('register_error', e);
      throw RegistrationException(errorMsg);
    }
  }

  Future<void> sendVerificationCode(String email) async {
    try {
      _analytics.logEvent('verification_code_request', {'email': email});

      final result = await _httpService.postRequest(
        "/api/v1/user/send-code",
        {'email': email},
      );

      if (result['status'] != 'success') {
        _analytics.logError('verification_code_failed', result['message']);
        throw VerificationException(result['message'] ?? 'Failed to send verification code');
      }

      _analytics.logEvent('verification_code_sent', {'email': email});
    } catch (e) {
      final errorMsg = _errorHandler.handleError(e);
      _analytics.logError('verification_code_error', e);
      throw VerificationException(errorMsg);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String verificationCode,
  }) async {
    try {
      _analytics.logEvent('password_reset_attempt', {'email': email});

      final result = await _httpService.postRequest(
        "/api/v1/user/reset-password",
        {
          'email': email,
          'password': newPassword,
          'email_code': verificationCode,
        },
      );

      if (result['status'] != 'success') {
        _analytics.logError('password_reset_failed', result['message']);
        throw PasswordResetException(result['message'] ?? 'Failed to reset password');
      }

      _analytics.logEvent('password_reset_success', {'email': email});
    } catch (e) {
      final errorMsg = _errorHandler.handleError(e);
      _analytics.logError('password_reset_error', e);
      throw PasswordResetException(errorMsg);
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        try {
          await _httpService.postRequest(
            "/api/v1/user/logout",
            {},
            headers: {'Authorization': token},
          );
        } catch (e) {
          if (kDebugMode) {
            print('Server logout failed: $e');
          }
        }
      }

      // 清除缓存和token
      await _clearAuthData();
      _analytics.logEvent('user_logged_out');
    } catch (e) {
      final errorMsg = _errorHandler.handleError(e);
      _analytics.logError('logout_error', e);
      throw Exception(errorMsg);
    }
  }

  Future<void> _clearAuthData() async {
    await clearAllTokens();
    await _cacheManager.clearAllCache();
  }

  Future<bool> validateToken(String token) async {
    try {
      final result = await _httpService.postRequest(
        "/api/v1/user/validate-token",
        {},
        headers: {'Authorization': token},
      );

      return result['status'] == 'success';
    } catch (e) {
      _errorHandler.handleError(e);
      return false;
    }
  }
}