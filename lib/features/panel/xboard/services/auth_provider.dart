import 'package:flutter/foundation.dart';
//import 'package:hiddify/features/panel/xboard/services/http_service/http_service.dart';
import '../core/storage/xboard_cache_manager.dart';
import '../utils/storage/token_storage.dart';
import '../../xboard/models/auth/auth_result.dart';
//import '../core/error/error_handler.dart';
import 'package:hiddify/features/panel/xboard/providers/index.dart';

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
      final result = await _httpService.postRequest(
        "/api/v1/user/login",
        {
          'email': email,
          'password': password,
        },
      );

      if (result['status'] != 'success') {
        throw AuthenticationException(result['message'] ?? 'Login failed');
      }

      final authData = result['data'];
      if (authData == null) {
        throw AuthenticationException('Invalid response data');
      }

      await _storeAuthTokens(authData);
      _analytics.logEvent('user_logged_in', {'email': email});

      return AuthResult(
        token: authData['token'],
        user: authData['user'],
        paymentTokens: authData['payment_tokens'],
      );
    } catch (e) {
      _errorHandler.handleError(e);
      _analytics.logError('login_failed', e);
      rethrow;
    }
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String emailCode,
    String? inviteCode,
  }) async {
    try {
      final result = await _httpService.postRequest(
        "/api/v1/user/register",
        {
          'email': email,
          'password': password,
          'email_code': emailCode,
          if (inviteCode != null) 'invite_code': inviteCode,
        },
      );

      if (result['status'] != 'success') {
        throw RegistrationException(result['message'] ?? 'Registration failed');
      }

      final authData = result['data'];
      if (authData == null) {
        throw RegistrationException('Invalid response data');
      }

      await _storeAuthTokens(authData);
      _analytics.logEvent('user_registered', {'email': email});

      return AuthResult(
        token: authData['token'],
        user: authData['user'],
        paymentTokens: authData['payment_tokens'],
      );
    } catch (e) {
      _errorHandler.handleError(e);
      _analytics.logError('registration_failed', e);
      rethrow;
    }
  }

  Future<void> sendVerificationCode(String email) async {
    try {
      final result = await _httpService.postRequest(
        "/api/v1/user/send-code",
        {'email': email},
      );

      if (result['status'] != 'success') {
        throw VerificationException(result['message'] ?? 'Failed to send verification code');
      }

      _analytics.logEvent('verification_code_sent', {'email': email});
    } catch (e) {
      _errorHandler.handleError(e);
      _analytics.logError('verification_code_failed', e);
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String verificationCode,
  }) async {
    try {
      final result = await _httpService.postRequest(
        "/api/v1/user/reset-password",
        {
          'email': email,
          'new_password': newPassword,
          'verification_code': verificationCode,
        },
      );

      if (result['status'] != 'success') {
        throw PasswordResetException(result['message'] ?? 'Failed to reset password');
      }

      _analytics.logEvent('password_reset_success', {'email': email});
    } catch (e) {
      _errorHandler.handleError(e);
      _analytics.logError('password_reset_failed', e);
      rethrow;
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

      await _clearAuthData();
      _analytics.logEvent('user_logged_out');
    } catch (e) {
      _errorHandler.handleError(e);
      _analytics.logError('logout_failed', e);
      rethrow;
    }
  }

  Future<void> _storeAuthTokens(Map<String, dynamic> authData) async {
    await storeToken(authData['token']);

    if (authData['payment_tokens'] != null) {
      final paymentTokens = authData['payment_tokens'] as Map<String, dynamic>;

      if (paymentTokens['stripe_token'] != null) {
        await storeStripeToken(paymentTokens['stripe_token']);
      }

      if (paymentTokens['revenuecat_token'] != null) {
        await storeRevenueCatToken(paymentTokens['revenuecat_token']);
      }
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

class AuthResult {
  final String token;
  final Map<String, dynamic> user;
  final Map<String, dynamic>? paymentTokens;

  AuthResult({
    required this.token,
    required this.user,
    this.paymentTokens,
  });
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}

class RegistrationException implements Exception {
  final String message;
  RegistrationException(this.message);
}

class VerificationException implements Exception {
  final String message;
  VerificationException(this.message);
}

class PasswordResetException implements Exception {
  final String message;
  PasswordResetException(this.message);
}