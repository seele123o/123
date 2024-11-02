// lib/features/app_update/data/github_release_parser.dart

import 'package:dartx/dartx.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:hiddify/features/app_update/model/remote_version_entity.dart';

abstract class GithubReleaseParser {
  static RemoteVersionEntity parse(Map<String, dynamic> json) {
    // 判断是否为 OSS 格式的响应
    if (json.containsKey('version') && !json.containsKey('tag_name')) {
      return _parseOssResponse(json);
    }
    return _parseGithubResponse(json);
  }

  static RemoteVersionEntity _parseGithubResponse(Map<String, dynamic> json) {
    final fullTag = json['tag_name'] as String;
    final fullVersion = fullTag.removePrefix("v").split("-").first.split("+");
    var version = fullVersion.first;
    var buildNumber = fullVersion.elementAtOrElse(1, (index) => "");
    var flavor = Environment.prod;

    for (final env in Environment.values) {
      final suffix = ".${env.name}";
      if (version.endsWith(suffix)) {
        version = version.removeSuffix(suffix);
        flavor = env;
        break;
      } else if (buildNumber.endsWith(suffix)) {
        buildNumber = buildNumber.removeSuffix(suffix);
        flavor = env;
        break;
      }
    }

    final preRelease = json["prerelease"] as bool;
    final publishedAt = DateTime.parse(json["published_at"] as String);

    return RemoteVersionEntity(
      version: version,
      buildNumber: buildNumber,
      releaseTag: fullTag,
      preRelease: preRelease,
      url: json["html_url"] as String,
      publishedAt: publishedAt,
      flavor: flavor,
    );
  }

  static RemoteVersionEntity _parseOssResponse(Map<String, dynamic> json) {
    final version = json['version'] as String;
    final buildNumber = json['build_number'] as String? ?? '';
    final preRelease = json['pre_release'] as bool? ?? false;
    final publishedAt = DateTime.parse(json['published_at'] as String);
    final flavor = Environment.values.firstWhere(
      (e) => e.name == (json['flavor'] as String? ?? Environment.prod.name),
      orElse: () => Environment.prod,
    );
    final fullTag = "v$version";

    return RemoteVersionEntity(
      version: version,
      buildNumber: buildNumber,
      releaseTag: fullTag,
      preRelease: preRelease,
      url: json["download_url"] as String,
      publishedAt: publishedAt,
      flavor: flavor,
    );
  }
}