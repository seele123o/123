// views/login_view.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/auth_service.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/http_service.dart'; // 添加
import 'package:hiddify/features/panel/xboard/viewmodels/login_viewmodel/login_viewmodel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 更新 provider
final loginViewModelProvider = ChangeNotifierProvider((ref) {
  return LoginViewModel(
    authService: ref.watch(authServiceProvider),
    httpService: ref.watch(httpServiceProvider),
  );
});

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final loginViewModel = ref.watch(loginViewModelProvider);
    final t = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
          // 移除 DomainCheckIndicator
          ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 600 ? 500 : constraints.maxWidth * 0.9,
                ),
                child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // 图标和欢迎文本保持不变
                      Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 20),
                      Text.rich(
                          // ... 保持不变
                          ),
                      const SizedBox(height: 20),
                      // 用户名输入框
                      TextFormField(
                        controller: loginViewModel.usernameController,
                        decoration: InputDecoration(
                          labelText: t.login.username,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // 密码输入框
                      TextFormField(
                        controller: loginViewModel.passwordController,
                        decoration: InputDecoration(
                          labelText: t.login.password,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      // 记住我选项
                      Row(
                        children: [
                          Checkbox(
                            value: loginViewModel.isRememberMe,
                            onChanged: (value) {
                              loginViewModel.toggleRememberMe(value ?? false);
                            },
                          ),
                          Text(t.login.rememberMe),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // 登录按钮
                      if (loginViewModel.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        ElevatedButton(
                          onPressed: () async {
                            final email = loginViewModel.usernameController.text;
                            final password = loginViewModel.passwordController.text;
                            try {
                              await loginViewModel.login(
                                email,
                                password,
                                context,
                                ref,
                              );
                              if (context.mounted) {
                                context.go('/');
                              }
                            } catch (e) {
                              // 显示错误提示
                              if (loginViewModel.error != null) {
                                _showErrorSnackbar(
                                  context,
                                  "${t.login.loginErr}: ${loginViewModel.error}",
                                  Colors.red,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            t.login.loginButton,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      // 底部链接保持不变
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              context.go('/forget-password');
                            },
                            child: Text(
                              t.login.forgotPassword,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go('/register');
                            },
                            child: Text(
                              t.login.register,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
