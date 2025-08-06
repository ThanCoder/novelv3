import 'dart:io';
import 'dart:isolate';

import '../novel_dir_db.dart';

class NovelServices {
  static Future<List<Novel>> getList() async {
    final rootPath = FolderFileServices.getSourcePath();

    return await Isolate.run<List<Novel>>(() async {
      List<Novel> list = [];
      try {
        final dir = Directory(rootPath);
        if (!dir.existsSync()) {
          NovelDirDb.showDebugLog('[not found!]: $rootPath',
              tag: 'NovelServices:getList');
          return list;
        }
        // found
        for (var file in dir.listSync()) {
          // dir မဟုတ်ရင် ကျော်မယ်
          if (file.statSync().type != FileSystemEntityType.directory) continue;
          // dir ပဲယူမယ်
          list.add(Novel.fromPath(file.path));
        }
      } catch (e) {
        NovelDirDb.showDebugLog(e.toString(), tag: 'NovelServices:getList');
      }
      return list;
    });
  }
}
