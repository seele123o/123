import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_version_entity.freezed.dart'; // 指定生成的代码文件
part 'remote_version_entity.g.dart'; // 如果需要 JSON 序列化，可以添加这个生成的文件

@freezed
class RemoteVersionEntity with _$RemoteVersionEntity {
  const factory RemoteVersionEntity({
    required String version,
    required String releaseNotes,
    required DateTime releaseDate,
    required String downloadUrl,
  }) = _RemoteVersionEntity;

  factory RemoteVersionEntity.fromJson(Map<String, dynamic> json) =>
      _$RemoteVersionEntityFromJson(json);
}
