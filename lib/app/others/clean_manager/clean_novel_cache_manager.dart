import 'dart:io';
import 'dart:isolate';

import 'package:novel_v3/app/others/clean_manager/clean_manager.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';
import 'package:than_pkg/than_pkg.dart';

class CleanNovelCacheManager extends CleanManager {
  CleanNovelCacheManager() : super(root: Directory(PathUtil.getSourcePath()));

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
            final name = file.getName();

            if (name == 'cover.png') continue;
            if (!name.endsWith('.png')) continue;
            files.add(file);
            count++;
            size += file.getSize;
          } else if (file.isDirectory) {
            await scanDir(Directory(file.path));
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
