import 'dart:io';

import 'package:hiddify/gen/fonts.gen.dart';
import 'package:hiddify/gen/translations.g.dart';

extension AppLocaleX on AppLocale {
  String get preferredFontFamily => !Platform.isWindows ? "" : FontFamily.emoji;

  String get localeName => switch (flutterLocale.toString()) {
        "en" => "English",
        "zh" || "zh_CN" => "中文 (中国)",
        "zh_TW" => "中文 (台湾)",
        "ru" => "Русский",
        _ => "English",  // Default to English for unsupported languages
      };
}
