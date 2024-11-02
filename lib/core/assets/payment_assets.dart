// lib/core/assets/payment_assets.dart
class PaymentAssets {
  static const String _baseImagePath = 'assets/images/payment';

  // Provider Logos
  static const String stripeLogo = '$_baseImagePath/stripe_logo.png';
  static const String revenueCatLogo = '$_baseImagePath/revenuecat_logo.png';

  // Payment Method Icons
  static const String creditCardIcon = '$_baseImagePath/icons/credit_card.svg';
  static const String applePay = '$_baseImagePath/icons/apple_pay.svg';
  static const String googlePay = '$_baseImagePath/icons/google_pay.svg';
  static const String alipay = '$_baseImagePath/icons/alipay.svg';
  static const String wechatPay = '$_baseImagePath/icons/wechat_pay.svg';

  // Status Icons
  static const String successIcon = '$_baseImagePath/icons/success.svg';
  static const String errorIcon = '$_baseImagePath/icons/error.svg';
  static const String pendingIcon = '$_baseImagePath/icons/pending.svg';

  // 生成SVG内容的方法
  static String getStripeLogoSvg() => '''
<svg width="100" height="40" viewBox="0 0 100 40" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect width="100" height="40" rx="8" fill="#6772E5"/>
  <path d="M49.5 20C49.5 25.6 44.8 30 39 30C33.2 30 28.5 25.6 28.5 20C28.5 14.4 33.2 10 39 10C44.8 10 49.5 14.4 49.5 20Z" fill="white"/>
  <path d="M71.5 20C71.5 25.6 66.8 30 61 30C55.2 30 50.5 25.6 50.5 20C50.5 14.4 55.2 10 61 10C66.8 10 71.5 14.4 71.5 20Z" fill="white" fill-opacity="0.5"/>
</svg>
''';

  static String getRevenueCatLogoSvg() => '''
<svg width="100" height="40" viewBox="0 0 100 40" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect width="100" height="40" rx="8" fill="#E02D69"/>
  <path d="M30 15L40 25M40 15L30 25" stroke="white" stroke-width="2"/>
  <circle cx="50" cy="20" r="8" stroke="white" stroke-width="2"/>
  <path d="M60 15H70V25H60V15Z" stroke="white" stroke-width="2"/>
</svg>
''';
}
