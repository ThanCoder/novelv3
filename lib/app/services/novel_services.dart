import 'dart:io';
import 'dart:isolate';

import '../novel_dir_app.dart';

class NovelServices {
  static Future<List<Novel>> getList({bool isAllCalc = false}) async {
    final rootPath = FolderFileServices.getSourcePath();

    return await Isolate.run<List<Novel>>(() async {
      List<Novel> list = [];
      try {
        final dir = Directory(rootPath);
        if (!dir.existsSync()) {
          NovelDirApp.showDebugLog(
            '[not found!]: $rootPath',
            tag: 'NovelServices:getList',
          );
          return list;
        }
        // found
        for (var file in dir.listSync(followLinks: false)) {
          // dir မဟုတ်ရင် ကျော်မယ်
          if (file.statSync().type != FileSystemEntityType.directory) continue;
          // dir ပဲယူမယ်
          final novel = Novel.fromPath(file.path);
          if (isAllCalc) {
            // တွက်ပြီးထည့်မယ်
            final descLines = await File(novel.getContentPath).readAsLines();
            novel.cacheIsExistsDesc = descLines.isNotEmpty;
            // calc all size
            novel.cacheSize = await novel.getAllSize();
          }
          list.add(novel);
        }
        // sort
      } catch (e) {
        NovelDirApp.showDebugLog(e.toString(), tag: 'NovelServices:getList');
      }
      return list;
    });
  }
}
