// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RemoteProfileEntityImpl _$$RemoteProfileEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$RemoteProfileEntityImpl(
      id: json['id'] as String,
      active: json['active'] as bool,
      name: json['name'] as String,
      url: json['url'] as String,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      testUrl: json['testUrl'] as String?,
      options: json['options'] == null
          ? null
          : ProfileOptions.fromJson(json['options'] as Map<String, dynamic>),
      subInfo: json['subInfo'] == null
          ? null
          : SubscriptionInfo.fromJson(json['subInfo'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$RemoteProfileEntityImplToJson(
        _$RemoteProfileEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'active': instance.active,
      'name': instance.name,
      'url': instance.url,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'testUrl': instance.testUrl,
      'options': instance.options?.toJson(),
      'subInfo': instance.subInfo?.toJson(),
      'runtimeType': instance.$type,
    };

_$LocalProfileEntityImpl _$$LocalProfileEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$LocalProfileEntityImpl(
      id: json['id'] as String,
      active: json['active'] as bool,
      name: json['name'] as String,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      testUrl: json['testUrl'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$LocalProfileEntityImplToJson(
        _$LocalProfileEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'active': instance.active,
      'name': instance.name,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'testUrl': instance.testUrl,
      'runtimeType': instance.$type,
    };

_$ProfileOptionsImpl _$$ProfileOptionsImplFromJson(Map<String, dynamic> json) =>
    _$ProfileOptionsImpl(
      updateInterval:
          Duration(microseconds: (json['updateInterval'] as num).toInt()),
    );

Map<String, dynamic> _$$ProfileOptionsImplToJson(
        _$ProfileOptionsImpl instance) =>
    <String, dynamic>{
      'updateInterval': instance.updateInterval.inMicroseconds,
    };

_$SubscriptionInfoImpl _$$SubscriptionInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$SubscriptionInfoImpl(
      upload: (json['upload'] as num).toInt(),
      download: (json['download'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      expire: DateTime.parse(json['expire'] as String),
      webPageUrl: json['webPageUrl'] as String?,
      supportUrl: json['supportUrl'] as String?,
    );

Map<String, dynamic> _$$SubscriptionInfoImplToJson(
        _$SubscriptionInfoImpl instance) =>
    <String, dynamic>{
      'upload': instance.upload,
      'download': instance.download,
      'total': instance.total,
      'expire': instance.expire.toIso8601String(),
      'webPageUrl': instance.webPageUrl,
      'supportUrl': instance.supportUrl,
    };
