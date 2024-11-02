// viewmodels/register_viewmodel.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/auth_service.dart';
import 'package:hiddify/features/panel/xboard/core/config/payment_config.dart'; // 添加
import 'package:hiddify/core/localization/translations.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService;
  // 添加 FormKey
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCountingDown = false;
  bool get isCountingDown => _isCountingDown;

  int _countdownTime = 60;
  int get countdownTime => _countdownTime;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController inviteCodeController = TextEditingController();
  final TextEditingController emailCodeController = TextEditingController();

  RegisterViewModel({required AuthService authService}) : _authService = authService;

  Future<void> sendVerificationCode(BuildContext context) async {
    final email = emailController.text.trim();
    _isCountingDown = true;
    _countdownTime = 60;
    notifyListeners();

    try {
      final response = await _authService.sendVerificationCode(email);

      if (response["status"] == "success") {
        _showSnackbar(context, "Verification code sent to $email");
      } else {
        _showSnackbar(context, response["message"].toString());
      }
    } catch (e) {
      _showSnackbar(context, "Error: $e");
    }

    // 倒计时逻辑
    while (_countdownTime > 0) {
      await Future.delayed(const Duration(seconds: 1));
      _countdownTime--;
      notifyListeners();
    }

    _isCountingDown = false;
    notifyListeners();
  }

  Future<void> register(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
        inviteCodeController.text.trim(),
        emailCodeController.text.trim(),
      );

      if (result["status"] == "success") {
        // 处理支付相关的令牌
        if (result['payment_tokens'] != null) {
          final tokens = result['payment_tokens'] as Map<String, dynamic>;
          if (tokens['stripe_token'] != null) {
            await storeStripeToken(tokens['stripe_token']);
          }
          if (tokens['revenuecat_token'] != null) {
            await storeRevenueCatToken(tokens['revenuecat_token']);
          }
        }

        // 预加载支付配置
        await PaymentConfig.getConfig();

        _showSnackbar(context, "Registration successful");
        if (context.mounted) {
          context.go('/login');
        }
      } else {
        _showSnackbar(context, result["message"].toString());
      }
    } catch (e) {
      _showSnackbar(context, "Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    inviteCodeController.dispose();
    emailCodeController.dispose();
    super.dispose();
  }
}
