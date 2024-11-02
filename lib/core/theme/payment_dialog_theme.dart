// lib/core/theme/payment_dialog_theme.dart
import 'package:flutter/material.dart';

class PaymentDialogTheme {
  static ThemeData dialogTheme(BuildContext context, ThemeData baseTheme) {
    return baseTheme.copyWith(
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      // 支付方式图标主题
      iconTheme: IconThemeData(
        size: 24,
        color: Theme.of(context).primaryColor,
      ),
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      // 处理中指示器主题
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.blue,
        linearTrackColor: Colors.blue,
      ),
    );
  }

  // 支付方式选择卡片样式
  static BoxDecoration paymentMethodCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // 价格卡片样式
  static BoxDecoration priceCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: Colors.grey.withOpacity(0.2),
    ),
  );

  // 处理中状态样式
  static BoxDecoration processingDecoration = BoxDecoration(
    color: Colors.black.withOpacity(0.5),
    borderRadius: BorderRadius.circular(8),
  );
}