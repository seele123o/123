import '../../../../../core/storage/storage_manager.dart';
import '../../../../../core/storage/cache_analytics.dart';

class XboardCacheManager {
  static const String _featureKey = 'xboard';
  static const Duration _defaultCacheDuration = Duration(hours: 24);

  final StorageManager _storageManager;

  XboardCacheManager._internal() : _storageManager = StorageManager();
  static final XboardCacheManager _instance = XboardCacheManager._internal();
  factory XboardCacheManager() => _instance;

  // 生成特定于xboard的缓存键
  String _getCacheKey(String key) => '${_featureKey}_$key';

  // 缓存数据
  Future<void> cacheData<T>({
    required String key,
    required T data,
    Duration? duration,
  }) async {
    final cacheKey = _getCacheKey(key);
    try {
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': duration?.inMilliseconds ?? _defaultCacheDuration.inMilliseconds,
      };
      
      await _storageManager.setValue(cacheKey, jsonEncode(cacheData));
      CacheAnalytics.trackCacheHit(_featureKey, key);
    } catch (e) {
      CacheAnalytics.trackCacheError(_featureKey, key, e.toString());
      rethrow;
    }
  }

  // 获取缓存数据
  Future<T?> getCachedData<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final cacheKey = _getCacheKey(key);
    try {
      final cachedString = _storageManager.getValue<String>(cacheKey);
      if (cachedString == null) {
        CacheAnalytics.trackCacheMiss(_featureKey, key);
        return null;
      }

      final cacheData = jsonDecode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final expiry = cacheData['expiry'] as int;
      
      // 检查是否过期
      if (DateTime.now().millisecondsSinceEpoch - timestamp > expiry) {
        CacheAnalytics.trackCacheMiss(_featureKey, key);
        await _storageManager.removeValue(cacheKey);
        return null;
      }

      CacheAnalytics.trackCacheHit(_featureKey, key);
      return fromJson(cacheData['data'] as Map<String, dynamic>);
    } catch (e) {
      CacheAnalytics.trackCacheError(_featureKey, key, e.toString());
      return null;
    }
  }

  // 清除特定缓存
  Future<void> clearCache(String key) async {
    await _storageManager.removeValue(_getCacheKey(key));
  }

  // 清除所有xboard相关的缓存
  Future<void> clearAllCache() async {
    final allKeys = _storageManager.prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(_featureKey)) {
        await _storageManager.removeValue(key);
      }
    }
  }
}