import 'dart:io';
import 'dart:isolate';

import 'package:novel_v3/app/extensions/pdf_extension.dart';
import 'package:than_pkg/than_pkg.dart';

import '../novel_dir_app.dart';

class PdfServices {
  static Future<List<NovelPdf>> getScanList() async {
    final pathList = await getScanPathList();
    final filterList = getFilterList();

    return await Isolate.run<List<NovelPdf>>(() async {
      List<NovelPdf> list = [];

      void scanDir(Directory dir) {
        for (var file in dir.listSync()) {
          // dir အနေမှာ စစ်မယ်
          //. စရင် ကျော်မယ်
          if (file.getName().startsWith('.')) continue;
          // list ထဲက ဟာတွေကျော်မယ်
          if (filterList.contains(file.getName())) continue;

          if (file.isFile()) {
            // pdf စစ်မယ်
            if (NovelPdf.isPdf(file.path)) {
              list.add(NovelPdf.createPath(file.path));
            }
          } else if (file.isDirectory()) {
            // scan လုပ်မယ်
            scanDir(Directory(file.path));
          }
        }
      }

      // scan
      for (var path in pathList) {
        final dir = Directory(path);
        if (!dir.isDirectory()) continue;
        scanDir(dir);
      }
      // sort လုပ်မယ်
      list.sortDate();

      return list;
    });
  }

  static Future<List<NovelPdf>> getList(String novelPath) async {
    return await Isolate.run<List<NovelPdf>>(() async {
      List<NovelPdf> list = [];
      try {
        final dir = Directory(novelPath);
        if (!dir.existsSync()) {
          NovelDirApp.showDebugLog(
            '[not found!]: $novelPath',
            tag: 'PdfServices:getList',
          );
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
        NovelDirApp.showDebugLog(e.toString(), tag: 'PdfServices:getList');
      }
      return list;
    });
  }

  static Future<List<String>> getScanPathList() async {
    List<String> list = [];
    final rootPath = await ThanPkg.platform.getAppExternalPath();
    if (rootPath == null) return list;
    if (Platform.isLinux) {
      list.add('$rootPath/Documents');
      list.add('$rootPath/Music');
      list.add('$rootPath/Pictures');
      list.add('$rootPath/Videos');
      list.add('$rootPath/Downloads');
    }
    if (Platform.isAndroid) {
      list.add(rootPath);
    }
    return list;
  }

  static List<String> getFilterList() {
    return ['Android', 'DCIM'];
  }
}
