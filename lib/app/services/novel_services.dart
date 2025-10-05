import 'dart:io';
import 'dart:isolate';

import 'package:novel_v3/app/core/factorys/file_scanner_factory.dart';
import 'package:than_pkg/extensions/index.dart';
import '../novel_dir_app.dart';

class NovelServices {
  static Future<List<Novel>> getList({
    bool isAllCalc = false,
    bool isCached = true,
  }) async {
    final rootPath = FolderFileServices.getSourcePath();
    if (isAllCalc) {
      return await getNovelAllCal(rootPath);
    } else {
      return await FileScannerFactory.getScanner<Novel>().getList(rootPath);
    }
  }

  // static Future<List<Novel>> getCacheList() async {
  //   List<Novel> list = [];
  //   try {
  //     final rootPath = FolderFileServices.getSourcePath();
  //     final dbFile = File(PathUtil.getCachePath(name: 'folder.db.json'));
  //     final rootDir = Directory(rootPath);
  //     // ရှိနေရင်
  //     if (dbFile.existsSync()) {
  //       // check db type
  //       try {
  //         final map = jsonDecode(await dbFile.readAsString());
  //         final db = NovelFolderCache.fromMap(map);
  //         if (rootDir.getDate.millisecondsSinceEpoch == db.dateInt) {
  //           return db.list;
  //         }
  //       } catch (e) {
  //         debugPrint(
  //           '[NovelServices:getCacheList:dbFile.existsSync] ${e.toString()}',
  //         );
  //       }
  //     }
  //     list = await FileScannerFactory.getScanner<Novel>().getList(rootPath);
  //     // set db
  //     final db = NovelFolderCache(
  //       dateInt: File(rootPath).getDate.millisecondsSinceEpoch,
  //       list: list,
  //     );
  //     await dbFile.writeAsString(jsonEncode(db.toMap()));
  //     // await dbFile.writeAsString(
  //     //   JsonEncoder.withIndent(' ').convert(db.toMap()),
  //     // );
  //   } catch (e) {
  //     debugPrint('[NovelServices:getCacheList]: ${e.toString()}');
  //   }
  //   return list;
  // }

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
