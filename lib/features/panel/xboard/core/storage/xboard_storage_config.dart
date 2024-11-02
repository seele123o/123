class XboardStorageConfig {
  static const String userInfoKey = 'user_info';
  static const String planListKey = 'plan_list';
  static const String subscriptionKey = 'subscription';
  
  static const Duration userInfoCacheDuration = Duration(hours: 24);
  static const Duration planListCacheDuration = Duration(hours: 12);
  static const Duration subscriptionCacheDuration = Duration(minutes: 30);
}