import 'package:hiddify/core/preferences/preferences_provider.dart';
import 'package:hiddify/gen/translations.g.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_preferences.g.dart';

@Riverpod(keepAlive: true)
class LocalePreferences extends _$LocalePreferences with AppLogger {
  static const _supportedLocales = {
    AppLocale.en,
    AppLocale.zhCn,
    AppLocale.zhTw,
    AppLocale.ru,
  };

  @override
  AppLocale build() {
    final persisted =
        ref.watch(sharedPreferencesProvider).requireValue.getString("locale");
    if (persisted == null) {
      final deviceLocale = AppLocaleUtils.findDeviceLocale();
      // 如果设备语言不在支持的语言列表中，默认使用英语
      return _supportedLocales.contains(deviceLocale) ? deviceLocale : AppLocale.en;
    }

    // 处理简体中文的向后兼容
    if (persisted == "zh") {
      return AppLocale.zhCn;
    }

    try {
      final locale = AppLocale.values.byName(persisted);
      // 如果存储的语言不再支持范围内，返回英语
      return _supportedLocales.contains(locale) ? locale : AppLocale.en;
    } catch (e) {
      loggy.error("error setting locale: [$persisted]", e);
      return AppLocale.en;
    }
  }

  Future<void> changeLocale(AppLocale value) async {
    // 确保只能切换到支持的语言
    if (!_supportedLocales.contains(value)) {
      value = AppLocale.en;
    }
    state = value;
    await ref
        .read(sharedPreferencesProvider)
        .requireValue
        .setString("locale", value.name);
  }

  // 获取支持的语言列表
  Set<AppLocale> get supportedLocales => _supportedLocales;
}