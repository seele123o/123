// lib/features/app_update/data/app_update_repository.dart

import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/http_client/dio_http_client.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/model/environment.dart';
import 'package:hiddify/core/utils/exception_handler.dart';
import 'package:hiddify/features/app_update/data/github_release_parser.dart';
import 'package:hiddify/features/app_update/model/app_update_failure.dart';
import 'package:hiddify/features/app_update/model/remote_version_entity.dart';
import 'package:hiddify/utils/utils.dart';

abstract interface class AppUpdateRepository {
  TaskEither<AppUpdateFailure, RemoteVersionEntity> getLatestVersion({
    bool includePreReleases = false,
    Release release = Release.general,
  });
}

class AppUpdateRepositoryImpl
    with ExceptionHandler, InfraLogger
    implements AppUpdateRepository {
  AppUpdateRepositoryImpl({required this.httpClient});

  final DioHttpClient httpClient;
  static const ossUrl = String.fromEnvironment(
    'OSS_UPDATE_URL',
    defaultValue: 'https://your-oss-domain.com/app-updates/latest.json',
  );

  @override
  TaskEither<AppUpdateFailure, RemoteVersionEntity> getLatestVersion({
    bool includePreReleases = false,
    Release release = Release.general,
  }) {
    return exceptionHandler(
      () async {
        if (!release.allowCustomUpdateChecker) {
          throw Exception("custom update checkers are not supported");
        }

        // First try OSS update
        try {
          final ossResponse = await httpClient.get<Map<String, dynamic>>(ossUrl);
          if (ossResponse.statusCode == 200 && ossResponse.data != null) {
            final release = GithubReleaseParser.parse(ossResponse.data!);
            if (!includePreReleases && release.preRelease) {
              loggy.debug("OSS version is pre-release");
            } else {
              loggy.debug("Got update from OSS");
              return right(release);
            }
          }
        } catch (e) {
          loggy.debug("Failed to get update from OSS, falling back to GitHub");
        }

        // Fallback to GitHub
        final response = await httpClient.get<List>(Constants.githubReleasesApiUrl);
        if (response.statusCode != 200 || response.data == null) {
          loggy.warning("failed to fetch latest version info");
          return left(const AppUpdateFailure.unexpected());
        }

        final releases = response.data!.map(
          (e) => GithubReleaseParser.parse(e as Map<String, dynamic>),
        );

        late RemoteVersionEntity latest;
        if (includePreReleases) {
          latest = releases.first;
        } else {
          latest = releases.firstWhere((e) => e.preRelease == false);
        }
        loggy.debug("Got update from GitHub");
        return right(latest);
      },
      AppUpdateFailure.unexpected,
    );
  }
}