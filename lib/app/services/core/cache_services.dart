import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/utils/path_util.dart';

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
      if (file.statSync().type == FileSystemEntityType.directory) continue;
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
      if (file.statSync().type == FileSystemEntityType.directory) continue;
      await file.delete();
    }
  } catch (e) {
    debugPrint('cleanCache: ${e.toString()}');
  }
}
