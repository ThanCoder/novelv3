import 'dart:io';
import 'dart:isolate';

import '../novel_dir_app.dart';

class ChapterServices {
  static Future<List<Chapter>> getList(String novelPath) async {
    return await Isolate.run<List<Chapter>>(() async {
      List<Chapter> list = [];
      try {
        final dir = Directory(novelPath);
        if (!dir.existsSync()) {
          NovelDirApp.showDebugLog('[not found!]: $novelPath',
              tag: 'ChapterServices:getList');
          return list;
        }
        // found
        for (var file in dir.listSync()) {
          // file မဟုတ်ရင် ကျော်မယ်
          if (file.statSync().type != FileSystemEntityType.file) continue;
          // chapter ပဲယူမယ်
          if (!Chapter.isChapter(file.path)) continue;
          list.add(Chapter.createPath(file.path));
        }
        // sort
        list.sortNumber();
      } catch (e) {
        NovelDirApp.showDebugLog(e.toString(), tag: 'NovelServices:getList');
      }
      return list;
    });
  }
}
