import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class UpdateService {
  final ApiService apiService = ApiService();

  Future<Map<String, dynamic>> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final currentVersion = packageInfo.version;

    final currentBuild =
        int.tryParse(packageInfo.buildNumber) ?? 0;

    final result = await apiService.checkAppUpdate(
  currentBuild: currentBuild,
);
debugPrint(
  "UPDATE DEBUG: "
  "currentVersion=$currentVersion, "
  "currentBuild=$currentBuild, "
  "serverLatestVersion=${result["latestVersion"]}, "
  "serverLatestBuild=${result["buildNumber"]}, "
  "apkUrl=${result["apkUrl"]}",
);

    if (result["success"] != true) {
      return {
        "updateAvailable": false,
        "currentVersion": currentVersion,
        "currentBuild": currentBuild,
      };
    }

    final latestVersion =
        result["latestVersion"]?.toString() ?? "";

    final latestBuild =
        int.tryParse(
              result["buildNumber"]?.toString() ?? "0",
            ) ??
            0;

    final apkUrl =
        result["apkUrl"]?.toString() ?? "";

    final updateAvailable = _isNewerVersion(
      currentVersion,
      currentBuild,
      latestVersion,
      latestBuild,
    );

    return {
      ...result,
      "updateAvailable": updateAvailable,
      "currentVersion": currentVersion,
      "currentBuild": currentBuild,
      "latestVersion": latestVersion,
      "latestBuild": latestBuild,
      "apkUrl": apkUrl,
    };
  }

  bool _isNewerVersion(
    String currentVersion,
    int currentBuild,
    String latestVersion,
    int latestBuild,
  ) {
    final current = _parseVersion(currentVersion);
    final latest = _parseVersion(latestVersion);

    for (int i = 0; i < 3; i++) {
      if (latest[i] > current[i]) {
        return true;
      }

      if (latest[i] < current[i]) {
        return false;
      }
    }

    return latestBuild > currentBuild;
  }

  List<int> _parseVersion(String version) {
    final parts = version.split(".");

    return [
      parts.isNotEmpty
          ? int.tryParse(parts[0]) ?? 0
          : 0,
      parts.length > 1
          ? int.tryParse(parts[1]) ?? 0
          : 0,
      parts.length > 2
          ? int.tryParse(parts[2]) ?? 0
          : 0,
    ];
  }
Future<void> downloadAndInstallApk({
  required String apkUrl,
  void Function(double progress)? onProgress,
}) async {
  const channel = MethodChannel(
    'order_management/apk_installer',
  );

  final response = await http.Client().send(
    http.Request(
      'GET',
      Uri.parse(apkUrl),
    ),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'APK download failed: HTTP ${response.statusCode}',
    );
  }

  final contentLength = response.contentLength ?? 0;

  final directory =
      await getTemporaryDirectory();

  final apkFile = File(
    '${directory.path}/order_management_update.apk',
  );

  if (await apkFile.exists()) {
    await apkFile.delete();
  }

  final fileSink = apkFile.openWrite();

  int downloaded = 0;

  try {
    await for (final chunk in response.stream) {

      downloaded += chunk.length;

      fileSink.add(chunk);

      if (contentLength > 0 &&
          onProgress != null) {

        onProgress(
          downloaded / contentLength,
        );
      }
    }
  } finally {
    await fileSink.close();
  }

  await channel.invokeMethod(
    'installApk',
    {
      'path': apkFile.path,
    },
  );
}
}