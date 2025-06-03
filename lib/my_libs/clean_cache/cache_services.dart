import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_pkg/extensions/file_system_entity_extension.dart';

import '../../app/utils/path_util.dart';

class CacheServices {
  static List<FileSystemEntity> getList() {
    List<FileSystemEntity> list = [];
    try {
      final cacheDir = Directory(PathUtil.getCachePath());
      final sourceDir = Directory(PathUtil.getSourcePath());

      final cacheFiles = cacheDir.listSync(recursive: true);

      for (var sourceFile in sourceDir.listSync()) {
        if (sourceFile.isFile()) {
          list.add(sourceFile);
        }
      }

      list.addAll(cacheFiles);
    } catch (e) {
      debugPrint('getCacheCount: ${e.toString()}');
    }
    return list;
  }

  static int getCount() {
    return getList().length;
  }

  static int getSize() {
    int res = 0;
    try {
      for (var file in getList()) {
        if (file.statSync().type == FileSystemEntityType.directory) continue;
        res += file.statSync().size;
      }
    } catch (e) {
      debugPrint('getCacheSize: ${e.toString()}');
    }
    return res;
  }

  static Future<void> clean() async {
    try {
      for (var file in getList()) {
        await file.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('cleanCache: ${e.toString()}');
    }
  }
}
