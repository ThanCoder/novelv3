import 'dart:io';
import 'dart:isolate';

import 'package:novel_v3/app/clean_manager/clean_manager.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:than_pkg/than_pkg.dart';

class CleanCacheManager extends CleanManager {
  CleanCacheManager() : super(root: Directory(PathUtil.getCachePath()));

  @override
  Future<CacheData> getCacheInfo() async {
    return await Isolate.run<CacheData>(() async {
      int count = 0;
      int size = 0;
      List<FileSystemEntity> files = [];
      // await Future.delayed(Duration(seconds: 2));

      Future<void> scanDir(Directory dir) async {
        for (var file in dir.listSync(followLinks: false)) {
          if (file.isFile) {
            files.add(file);
            count++;
            size += file.getSize;
          } else if (file.isDirectory) {
            await scanDir(Directory(file.path));
            // add dir
            files.add(file);
            count++;
          }
        }
      }

      await scanDir(root);

      return CacheData(
        size: size == 0 ? '0' : size.getSizeLabel(),
        count: count,
        files: files,
      );
    });
  }
}
