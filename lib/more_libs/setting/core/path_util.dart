import 'dart:io';

import 'package:flutter/services.dart';
import 'package:than_pkg/than_pkg.dart';
import '../setting.dart';

class PathUtil {
  static Future<String> getAssetRealPathPath(String rootPath) async {
    final bytes = await rootBundle.load('assets/$rootPath');
    final name = rootPath.getName();
    final cacheFile = File(PathUtil.getCachePath(name: name));
    if (!cacheFile.existsSync()) {
      await cacheFile.writeAsBytes(
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

  static String getSourcePath({String? name}) {
    final dirPath = createDir('${getHomePath()}/source');
    final fileName = (name != null && name.isNotEmpty) ? '/$name' : '';
    return '$dirPath$fileName';
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

  static Future<void> deleteDir(Directory directory) async {
    Future<void> scanDir(Directory dir) async {
      for (var file in dir.listSync(followLinks: false)) {
        if (file.isDirectory) {
          await scanDir(Directory(file.path));
          await file.delete();
        } else {
          await file.delete();
        }
      }
    }

    await scanDir(directory);
    await directory.delete(recursive: true);
  }

  static Future<void> renameDir({
    required Directory oldDir,
    required Directory newDir,
  }) async {
    if (oldDir.path == newDir.path) return;
    if (!oldDir.existsSync()) {
      throw Exception('Old Folder Not Found!');
    }
    if (newDir.existsSync()) {
      throw Exception('New Folder Already Exists');
    }
    // dir ဖန်တီး
    await newDir.create();
    //file move
    for (var file in oldDir.listSync(followLinks: false)) {
      final newPath = '${newDir.path}/${file.getName()}';
      await file.rename(newPath);
    }
    // old dir delete
    await oldDir.delete();
  }
}
