import 'dart:convert';
import 'dart:io';

import 'package:novel_v3/app/ui/novel_dir_app.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';

class NovelBookmarkServices {
  static Future<bool> isExists(String novelTitle) async {
    final index = (await getList()).indexWhere((e) => e == novelTitle);
    return index != -1;
  }

  static Future<void> toggle(String novelTitle) async {
    if (await isExists(novelTitle)) {
      // remove
      final res = (await getList()).where((e) => e != novelTitle).toList();
      await setList(res);
    } else {
      //add
      final res = await getList();
      res.insert(0, novelTitle);
      await setList(res);
    }
  }

  static Future<void> setList(List<String> list) async {
    try {
      final file = File(getPath);
      await file.writeAsString(JsonEncoder.withIndent(' ').convert(list));
    } catch (e) {
      NovelDirApp.showDebugLog(
        e.toString(),
        tag: 'NovelBookmarkServices:setList',
      );
    }
  }

  static Future<List<String>> getList() async {
    List<String> list = [];
    try {
      final file = File(getPath);
      if (!file.existsSync()) return list;

      List<dynamic> resList = jsonDecode(await file.readAsString());
      // filter title is exists
      for (var title in resList) {
        final dir = Directory('${PathUtil.getSourcePath()}/$title');
        if (!dir.existsSync()) continue;
        list.add(title);
      }
    } catch (e) {
      NovelDirApp.showDebugLog(
        e.toString(),
        tag: 'NovelBookmarkServices:getList',
      );
    }
    return list;
  }

  static String get getPath =>
      '${PathUtil.getLibaryPath()}/novel.bookmark.db.json';
}
