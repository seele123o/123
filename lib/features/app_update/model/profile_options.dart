import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_options.freezed.dart';  // 这行代码告诉生成工具生成 profile_options.freezed.dart 文件

@freezed
class ProfileOptions with _$ProfileOptions {
  const factory ProfileOptions({
    required Duration updateInterval,
  }) = _ProfileOptions;
}
