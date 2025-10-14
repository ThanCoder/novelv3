import 'dart:io';

import '../ui/novel_dir_app.dart';

class FolderFileServices {
  static String getSourcePath({String? name}) {
    return '${NovelDirApp.instance.getRootDirPath()}/source/${name ?? ''}';
  }

  static String getLibaryPath(String name) {
    return '${NovelDirApp.instance.getRootDirPath()}/libary/$name';
  }

  static String getCachePath(String name) {
    return '${NovelDirApp.instance.getRootDirPath()}/source/$name';
  }

  static Future<String> createDir(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create();
      }
    } catch (e) {
      NovelDirApp.showDebugLog(
        '${e.toString()} -> $path',
        tag: 'ServerFileServices:createDir',
      );
    }
    return path;
  }
}
