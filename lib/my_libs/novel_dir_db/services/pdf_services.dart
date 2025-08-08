import 'dart:io';
import 'dart:isolate';

import '../novel_dir_db.dart';

class PdfServices {
  static Future<List<NovelPdf>> getList(String novelPath) async {
    return await Isolate.run<List<NovelPdf>>(() async {
      List<NovelPdf> list = [];
      try {
        final dir = Directory(novelPath);
        if (!dir.existsSync()) {
          NovelDirDb.showDebugLog('[not found!]: $novelPath',
              tag: 'PdfServices:getList');
          return list;
        }
        // found
        for (var file in dir.listSync()) {
          // file မဟုတ်ရင် ကျော်မယ်
          if (file.statSync().type != FileSystemEntityType.file) continue;
          // Pdf ပဲယူမယ်
          if (!NovelPdf.isPdf(file.path)) continue;
          list.add(NovelPdf.createPath(file.path));
        }
        // sort
      } catch (e) {
        NovelDirDb.showDebugLog(e.toString(), tag: 'PdfServices:getList');
      }
      return list;
    });
  }
}
