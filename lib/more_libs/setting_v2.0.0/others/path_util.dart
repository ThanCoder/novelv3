import 'dart:io';

import 'package:flutter/services.dart';
import 'package:than_pkg/than_pkg.dart';
import '../setting.dart';

class PathUtil {
  static Future<String> getAssetRealPathPath(String rootPath) async {
    final bytes = await rootBundle.load('assets/$rootPath');
    final name = rootPath.getName();
    final cacheFile = File('${PathUtil.getCachePath()}/$name');
    if (!cacheFile.existsSync()) {
      cacheFile.writeAsBytesSync(
        bytes.buffer.asInt8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
    }
    return cacheFile.path;
  }

  static String getBasename(String path) {
    return path.split('/').last;
  }

  static String getHomePath({String? name}) {
    final dirPath = createDir(Setting.appRootPath);
    final fileName = (name != null && name.isNotEmpty) ? '/$name' : '';
    return '$dirPath$fileName';
  }

  static String getConfigPath({String? name}) {
    final dirPath = createDir('${getHomePath()}/config');
    final fileName = (name != null && name.isNotEmpty) ? '/$name' : '';
    return '$dirPath$fileName';
  }

  static String getLibaryPath({String? name}) {
    final dirPath = createDir('${getHomePath()}/libary');
    final fileName = (name != null && name.isNotEmpty) ? '/$name' : '';
    return '$dirPath$fileName';
  }

  static String getDatabasePath({String? name}) {
    final dirPath = createDir('${getHomePath()}/database');
    final fileName = (name != null && name.isNotEmpty) ? '/$name' : '';
    return '$dirPath$fileName';
  }

  static String getDatabaseSourcePath() {
    return createDir('${getHomePath()}/databaseSource');
  }

  static String getCachePath({String? name}) {
    String homeDir = createDir(Setting.appConfigPath);
    final dirPath = createDir('$homeDir/cache');
    final fileName = (name != null && name.isNotEmpty) ? '/$name' : '';
    return '$dirPath$fileName';
  }

  static String getSourcePath() {
    return createDir('${getHomePath()}/source');
  }

  static String getOutPath({String? name}) {
    String download = createDir(
      '${Setting.appExternalPath}/${Platform.isAndroid ? 'Download' : 'Downloads'}',
    );
    final dirPath = createDir('$download/${Setting.instance.appName}');
    final fileName = (name != null && name.isNotEmpty) ? '/$name' : '';
    return '$dirPath$fileName';
  }

  static String createDir(String path) {
    try {
      if (path.isEmpty) path;
      final dir = Directory(path);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
    } catch (e) {
      Setting.showDebugLog(e.toString(), tag: 'PathUtil:createDir');
    }
    return path;
  }
}
