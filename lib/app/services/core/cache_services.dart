import 'dart:io';

import 'package:flutter/material.dart';

import '../../utils/path_util.dart';

class CacheServices {
  static final CacheServices instance = CacheServices._();
  CacheServices._();
  factory CacheServices() => instance;

  int getCacheCount() {
    int res = 0;
    try {
      final dir = Directory(PathUtil.instance.getCachePath());
      final files = dir.listSync(recursive: true);
      res = files.length;
    } catch (e) {
      debugPrint('getCacheCount: ${e.toString()}');
    }
    return res;
  }

  int getCacheSize() {
    int res = 0;
    try {
      final dir = Directory(PathUtil.instance.getCachePath());
      final files = dir.listSync(recursive: true);
      for (var file in files) {
        // if (file.statSync().type == FileSystemEntityType.directory) continue;
        res += file.statSync().size;
      }
    } catch (e) {
      debugPrint('getCacheSize: ${e.toString()}');
    }
    return res;
  }

  Future<void> cleanCache() async {
    try {
      final dir = Directory(PathUtil.instance.getCachePath());
      final files = dir.list(recursive: true);
      await for (var file in files) {
        if (file.statSync().type == FileSystemEntityType.directory) {
          final dir = Directory(file.path);
          await dir.delete(recursive: true);
        } else {
          await file.delete(recursive: true);
        }
      }
    } catch (e) {
      debugPrint('cleanCache: ${e.toString()}');
    }
  }
}
