import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yaml/yaml.dart';

class ReleaseServices {
  static ReleaseServices instance = ReleaseServices._();
  bool isUsedReleaseFile = isUsedReleaseServiceFile;

  ReleaseServices._();

  String _version = '';

  Future<String> getRelease() async {
    String result = '';
    try {
      if (isUsedReleaseFile) {
        result = await getReleaseFile();
      } else {
        String releaseUrl = getParseReleaseUrl(githubUrl: githubUrl);
        final res = await Dio().get(releaseUrl);
        result = res.data.toString();
      }
    } catch (e) {
      debugPrint('getRelease: ${e.toString()}');
    }
    return result;
  }

  String getReleaseFilePath() {
    return '${Directory.current.path}/release.json';
  }

  Future<String> getReleaseFile() async {
    String result = '';
    try {
      final file = File(getReleaseFilePath());
      if (await file.exists()) {
        result = await file.readAsString();
      }
    } catch (e) {
      debugPrint('getRelease: ${e.toString()}');
    }
    return result;
  }

  Future<Map<String, dynamic>?> getLatestVersion() async {
    Map<String, dynamic>? resMap;
    try {
      final res = await getRelease();
      //is empty
      if (res.isEmpty) return resMap;

      Map<String, dynamic> map = jsonDecode(res);
      List<dynamic> platforms = map['versions'] ?? [];
      //check current plafrom
      for (var app in platforms) {
        // print('${app['platfrom']}-${Platform.operatingSystem}');
        if (app['platform'] == Platform.operatingSystem) {
          String currentVersion = getVersion();
          String requiredVersion = app['version'];
          //is required update
          if (currentVersion.compareTo(requiredVersion) < 0) {
            resMap = app;
          }
        }
      }
    } catch (e) {
      debugPrint('getLatestVersion: ${e.toString()}');
    }
    return resMap;
  }

  Future<bool> isLatestVersion() async {
    bool res = true;
    try {
      final map = await getLatestVersion();
      if (map != null) {
        res = false;
      }
    } catch (e) {
      debugPrint('isLatestVersion: ${e.toString()}');
    }
    return res;
  }

  String getParseReleaseUrl({required String githubUrl}) {
    // https://github.com/ThanCoder/novelv3
    // https://raw.githubusercontent.com/ThanCoder/novelv3/refs/heads/main/assets/online.webp
    String res = '';
    res = '${getParseRawUrl(githubUrl: githubUrl)}/release.json';

    return res;
  }

  String getParseRawUrl({required String githubUrl}) {
    String hostUrl = githubUrl.replaceAll(
        "https://github.com", 'https://raw.githubusercontent.com');
    return '$hostUrl/refs/heads/main';
  }

  String getVersion() {
    return _version;
    // String res = '0.0.0';
    // try {
    //   //yamal file load မယ်
    //   final yamlFile = File('${Directory.current.path}/pubspec.yaml');
    //   //မရှိရင်
    //   if (!yamlFile.existsSync()) {
    //     debugPrint('not found `pubspec.yaml`');
    //     return res;
    //   }
    //   final yaml = loadYaml(yamlFile.readAsStringSync());
    //   res = yaml['version'] ?? res;
    // } catch (e) {
    //   debugPrint('getVersion: ${e.toString()}');
    // }
    // return res;
  }

  Future<void> initReleaseService() async {
    try {
      final package = await PackageInfo.fromPlatform();
      _version = package.version;

      String res = await getRelease();

      if (res.isNotEmpty) return;
      //release file မရှိရင် ဖန်တီးမယ်
      //yamal file load မယ်
      final yamlFile = File('${Directory.current.path}/pubspec.yaml');
      //မရှိရင်
      if (!await yamlFile.exists()) {
        debugPrint('not found `pubspec.yaml`');
        return;
      }
      final yaml = loadYaml(await yamlFile.readAsString());

      //github url
      final githubUrl = yaml['repository'] ?? '';
      final readmeUrl = '${getParseRawUrl(githubUrl: githubUrl)}/README.md';
      final changelogUrl =
          '${getParseRawUrl(githubUrl: githubUrl)}/CHANGELOG.md';
      final coverUrl =
          '${getParseRawUrl(githubUrl: githubUrl)}/$defaultIconAssetsPath';

      final release = {
        "title": appTitle,
        "description": yaml['description'],
        "package_name": yaml['name'],
        "github_url": githubUrl,
        "cover_url": coverUrl,
        "changelog_url": readmeUrl,
        "reademe_url": changelogUrl,
        "versions": [
          {
            "platform": Platform.operatingSystem,
            "version": _version,
            "size": "10.0MB",
            "download_url": "",
            "direct_download_url": "",
            "content_urls": [],
            "description": "",
            "date": DateTime.now().millisecondsSinceEpoch,
          }
        ]
      };

      //save
      final releaseFile = File(getReleaseFilePath());
      await releaseFile
          .writeAsString(const JsonEncoder.withIndent('  ').convert(release));
    } catch (e) {
      debugPrint('initReleaseService: ${e.toString()}');
    }
  }
}
