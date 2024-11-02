// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_version_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RemoteVersionEntityImpl _$$RemoteVersionEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$RemoteVersionEntityImpl(
      version: json['version'] as String,
      releaseNotes: json['releaseNotes'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      downloadUrl: json['downloadUrl'] as String,
    );

Map<String, dynamic> _$$RemoteVersionEntityImplToJson(
        _$RemoteVersionEntityImpl instance) =>
    <String, dynamic>{
      'version': instance.version,
      'releaseNotes': instance.releaseNotes,
      'releaseDate': instance.releaseDate.toIso8601String(),
      'downloadUrl': instance.downloadUrl,
    };
