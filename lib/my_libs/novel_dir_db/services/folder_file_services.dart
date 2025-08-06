import 'dart:io';

import '../novel_dir_db.dart';

class FolderFileServices {
  static String getSourcePath({String? name}) {
    return '${NovelDirDb.instance.getRootDirPath()}/source/${name ?? ''}';
  }

  static String getLibaryPath(String name) {
    return '${NovelDirDb.instance.getRootDirPath()}/libary/$name';
  }

  static String getCachePath(String name) {
    return '${NovelDirDb.instance.getRootDirPath()}/source/$name';
  }

  static Future<String> createDir(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create();
      }
    } catch (e) {
      NovelDirDb.showDebugLog(
        '${e.toString()} -> $path',
        tag: 'ServerFileServices:createDir',
      );
    }
    return path;
  }
}
