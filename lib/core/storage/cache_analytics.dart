class CacheAnalytics {
  static final Map<String, int> _cacheHits = {};
  static final Map<String, int> _cacheMisses = {};
  static final Map<String, int> _cacheErrors = {};

  // 记录缓存命中
  static void trackCacheHit(String feature, String key) {
    final trackingKey = '${feature}_$key';
    _cacheHits[trackingKey] = (_cacheHits[trackingKey] ?? 0) + 1;
  }

  // 记录缓存未命中
  static void trackCacheMiss(String feature, String key) {
    final trackingKey = '${feature}_$key';
    _cacheMisses[trackingKey] = (_cacheMisses[trackingKey] ?? 0) + 1;
  }

  // 记录缓存错误
  static void trackCacheError(String feature, String key, String error) {
    final trackingKey = '${feature}_$key';
    _cacheErrors[trackingKey] = (_cacheErrors[trackingKey] ?? 0) + 1;
    // 可以添加错误日志记录
  }

  // 获取缓存统计信息
  static Map<String, dynamic> getCacheStats() {
    return {
      'hits': Map.from(_cacheHits),
      'misses': Map.from(_cacheMisses),
      'errors': Map.from(_cacheErrors),
    };
  }

  // 清除统计数据
  static void clearStats() {
    _cacheHits.clear();
    _cacheMisses.clear();
    _cacheErrors.clear();
  }
}