// lib/features/panel/xboard/utils/storage/token_storage.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenKeys {
  static const String authToken = 'auth_token';
  static const String stripeToken = 'stripe_token';
  static const String revenueCatToken = 'revenuecat_token';
  static const String subscriptionToken = 'subscription_token';
}

// 存储认证令牌
Future<void> storeToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(TokenKeys.authToken, token);
  if (kDebugMode) {
    print('Token stored: $token');
  }
}

// 获取认证令牌
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(TokenKeys.authToken);
}

// 删除认证令牌
Future<void> deleteToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(TokenKeys.authToken);
}

Future<void> storeSubscriptionToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(TokenKeys.subscriptionToken, token);
}

// 存储 Stripe 令牌
Future<void> storeStripeToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(TokenKeys.stripeToken, token);
  if (kDebugMode) {
    print('Stripe token stored: $token');
  }
}

// 获取 Stripe 令牌
Future<String?> getStripeToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(TokenKeys.stripeToken);
}

// 删除 Stripe 令牌
Future<void> deleteStripeToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(TokenKeys.stripeToken);
}

// 存储 RevenueCat 令牌
Future<void> storeRevenueCatToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(TokenKeys.revenueCatToken, token);
  if (kDebugMode) {
    print('RevenueCat token stored: $token');
  }
}

// 获取 RevenueCat 令牌
Future<String?> getRevenueCatToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(TokenKeys.revenueCatToken);
}

// 删除 RevenueCat 令牌
Future<void> deleteRevenueCatToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(TokenKeys.revenueCatToken);
}

// 清除所有支付相关令牌
Future<void> clearPaymentTokens() async {
  await deleteStripeToken();
  await deleteRevenueCatToken();
}

// 清除所有令牌
Future<void> clearAllTokens() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(TokenKeys.authToken);
  await prefs.remove(TokenKeys.stripeToken);
  await prefs.remove(TokenKeys.revenueCatToken);
}

// 检查令牌是否有效
bool isTokenValid(String? token) {
  if (token == null || token.isEmpty) return false;

  try {
    // TODO: 添加更多的令牌验证逻辑
    return true;
  } catch (e) {
    return false;
  }
}

// 获取所有存储的令牌
Future<Map<String, String?>> getAllTokens() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'auth_token': prefs.getString(TokenKeys.authToken),
    'stripe_token': prefs.getString(TokenKeys.stripeToken),
    'revenuecat_token': prefs.getString(TokenKeys.revenueCatToken),
  };
}
