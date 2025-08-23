import 'dart:io';

import 'package:novel_v3/app/factorys/file_scanner_factory.dart';
import '../novel_dir_app.dart';

class NovelServices {
  static Future<List<Novel>> getList({bool isAllCalc = false}) async {
    final rootPath = FolderFileServices.getSourcePath();
    var list = await FileScannerFactory.getScanner<Novel>().getList(rootPath);
    if (isAllCalc) {
      list = await getNovelAllCal(list);
    }
    return list;
  }

  static Future<List<Novel>> getNovelAllCal(List<Novel> list) async {
    list = list.map((e) {
      final desFile = File(e.getContentPath);
      if (desFile.existsSync()) {
        final lines = desFile.readAsLinesSync();
        e.cacheIsExistsDesc = lines.isNotEmpty;
      }
      return e;
    }).toList();
    return list;
  }
}
