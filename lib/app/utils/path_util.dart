import 'dart:io';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../notifiers/app_notifier.dart';

class PathUtil {
  static final PathUtil instance = PathUtil._();
  PathUtil._();
  factory PathUtil() => instance;

  String getBasename(String path) {
    return path.split('/').last;
  }

  String getHomePath() {
    return createDir(appRootPathNotifier.value);
  }

  String getConfigPath() {
    return createDir('${getHomePath()}/config');
  }

  String getLibaryPath() {
    return createDir('${getHomePath()}/libary');
  }

  String getDatabasePath() {
    return createDir('${getHomePath()}/database');
  }

  String getDatabaseSourcePath() {
    return createDir('${getHomePath()}/databaseSource');
  }

  String getCachePath() {
    String homeDir = createDir(appConfigPathNotifier.value);
    return createDir('$homeDir/cache');
  }

  String getSourcePath() {
    return createDir('${getHomePath()}/source');
  }

  String getOutPath() {
    String download = createDir(
        '${appExternalPathNotifier.value}/${Platform.isAndroid ? 'Download' : 'Downloads'}');
    return createDir('$download/$appName');
  }

  String createDir(String path) {
    try {
      if (path.isEmpty) path;
      final dir = Directory(path);
      if (!dir.existsSync()) {
        dir.createSync();
      }
    } catch (e) {
      debugPrint('createDir: ${e.toString()}');
    }
    return path;
  }
}
