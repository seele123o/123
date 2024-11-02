import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class StorageManager {
  static final StorageManager _instance = StorageManager._internal();
  
  factory StorageManager() => _instance;
  
  StorageManager._internal();

  static late final SharedPreferences _prefs;
  static late final Directory _appDocDir;

  // 初始化存储系统
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _appDocDir = await getApplicationDocumentsDirectory();
  }

  // 获取SharedPreferences实例
  SharedPreferences get prefs => _prefs;

  // 获取应用文档目录
  Directory get appDocDir => _appDocDir;

  // 通用存储方法
  Future<bool> setValue(String key, dynamic value) async {
    if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is int) {
      return await _prefs.setInt(key, value);
    } else if (value is double) {
      return await _prefs.setDouble(key, value);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      return await _prefs.setStringList(key, value);
    }
    throw UnimplementedError('Unsupported type: ${value.runtimeType}');
  }

  // 通用获取方法
  T? getValue<T>(String key) {
    return _prefs.get(key) as T?;
  }

  // 删除指定键值
  Future<bool> removeValue(String key) async {
    return await _prefs.remove(key);
  }

  // 清除所有数据
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}