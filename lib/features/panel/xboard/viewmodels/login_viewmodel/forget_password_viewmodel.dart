import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/auth_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart/';

class ForgetPasswordViewModel extends ChangeNotifier {
  final AuthService _authService;

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
  final TextEditingController emailCodeController = TextEditingController();

  ForgetPasswordViewModel({required AuthService authService}) : _authService = authService;

  Future<void> sendVerificationCode() async {
    final email = emailController.text.trim();
    _isCountingDown = true;
    _countdownTime = 60;
    notifyListeners();

    try {
      await _authService.sendVerificationCode(email);

      while (_countdownTime > 0) {
        await Future.delayed(const Duration(seconds: 1));
        _countdownTime--;
        notifyListeners();
      }
    } catch (e) {
      _isCountingDown = false;
      _countdownTime = 60;
      notifyListeners();

      if (kDebugMode) {
        print("发送验证码失败: $e");
      }
    }

    _isCountingDown = false;
    notifyListeners();
  }

  // 保留一个 resetPassword 实现
  Future<void> resetPassword(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final emailCode = emailCodeController.text.trim();

    try {
      await _authService.resetPassword(
        email: email,
        newPassword: password,
        verificationCode: emailCode,
      );
      if (context.mounted) {
        context.go('/login');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailCodeController.dispose();
    super.dispose();
  }
}