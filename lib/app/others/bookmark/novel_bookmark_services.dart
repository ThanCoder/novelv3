import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';

class NovelBookmarkServices {
  static Future<void> setList(List<NovelBookmark> list) async {
    final file = getDBFile;
    final contents = list.map((e) => e.toMap()).toList();
    await file.writeAsString(jsonEncode(contents));
  }

  static Future<List<NovelBookmark>> getAll() async {
    List<NovelBookmark> list = [];
    if (getDBFile.existsSync()) {
      try {
        List<dynamic> mapList = jsonDecode(await getDBFile.readAsString());
        list = mapList.map((map) => NovelBookmark.fromMap(map)).toList();
      } catch (e) {
        debugPrint('NovelBookmarkServices:getList - ${e.toString()}');
      }
    }
    return list;
  }

  static File get getDBFile =>
      File(PathUtil.getLibaryPath(name: NovelBookmark.getDBName));
}
