import 'dart:io';
import 'dart:isolate';

import 'package:novel_v3/app/factorys/file_scanner_factory.dart';
import 'package:than_pkg/extensions/index.dart';
import '../novel_dir_app.dart';

class NovelServices {
  static Future<List<Novel>> getList({bool isAllCalc = false}) async {
    final rootPath = FolderFileServices.getSourcePath();
    if (isAllCalc) {
      return await getNovelAllCal(rootPath);
    } else {
      return await FileScannerFactory.getScanner<Novel>().getList(rootPath);
    }
  }

  static Future<List<Novel>> getNovelAllCal(String rootPath) async {
    final dir = Directory(rootPath);
    if (!dir.existsSync()) return [];

    return await Isolate.run<List<Novel>>(() async {
      List<Novel> list = [];

      for (var file in dir.listSync(followLinks: false)) {
        if (!file.isDirectory) continue;

        final novel = Novel.fromPath(file.path);
        // cal desc
        final desFile = File(novel.getContentPath);
        if (desFile.existsSync()) {
          final lines = desFile.readAsLinesSync();
          novel.cacheIsExistsDesc = lines.isNotEmpty;
        }
        // all file size
        int size = 0;
        final dir = Directory(novel.path);
        for (var file in dir.listSync(followLinks: false)) {
          if (!file.isFile) continue;
          size += file.getSize;
        }
        novel.cacheSize = size;
        // add novel
        list.add(novel);
      }
      // sort
      list.sortDate();
      return list;
    });
  }
}
