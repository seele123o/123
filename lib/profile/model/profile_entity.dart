import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';  // 添加这行

part 'profile_entity.freezed.dart';
part 'profile_entity.g.dart';

@JsonEnum()  // 添加这个注解
enum ProfileType {
  remote,
  local;

  @override
  String toString() {
    return switch (this) {
      remote => 'remote',
      local => 'local',
    };
  }
}

@freezed
sealed class ProfileEntity with _$ProfileEntity {
  const ProfileEntity._();

  const factory ProfileEntity.remote({
    required String id,
    required bool active,
    required String name,
    required String url,
    required DateTime lastUpdate,
    String? testUrl,
    ProfileOptions? options,
    SubscriptionInfo? subInfo,
  }) = RemoteProfileEntity;

  const factory ProfileEntity.local({
    required String id,
    required bool active,
    required String name,
    required DateTime lastUpdate,
    String? testUrl,
  }) = LocalProfileEntity;

  factory ProfileEntity.fromJson(Map<String, dynamic> json) =>
      _$ProfileEntityFromJson(json);  // 添加这个工厂方法
}

@freezed
class ProfileOptions with _$ProfileOptions {
  const factory ProfileOptions({
    required Duration updateInterval,
  }) = _ProfileOptions;

  factory ProfileOptions.fromJson(Map<String, dynamic> json) =>
      _$ProfileOptionsFromJson(json);  // 添加这个工厂方法
}

@freezed
class SubscriptionInfo with _$SubscriptionInfo {
  const SubscriptionInfo._();

  const factory SubscriptionInfo({
    required int upload,
    required int download,
    required int total,
    required DateTime expire,
    String? webPageUrl,
    String? supportUrl,
  }) = _SubscriptionInfo;

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionInfoFromJson(json);  // 添加这个工厂方法

  bool get isExpired => expire <= DateTime.now();

  int get consumption => upload + download;

  double get ratio => (consumption / total).clamp(0, 1);

  Duration get remaining => expire.difference(DateTime.now());
}