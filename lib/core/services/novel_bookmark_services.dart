import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/other_apps/bookmark/novel_bookmark.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';

class NovelBookmarkServices {
  NovelBookmarkServices._();
  static final instance = NovelBookmarkServices._();
  factory NovelBookmarkServices() => instance;

  Future<void> setList(List<NovelBookmark> list) async {
    final file = getDBFile;
    final contents = list.map((e) => e.toJson()).toList();
    await file.writeAsString(jsonEncode(contents));
  }

  Future<List<NovelBookmark>> getAll() async {
    List<NovelBookmark> list = [];
    if (getDBFile.existsSync()) {
      try {
        List<dynamic> mapList = jsonDecode(await getDBFile.readAsString());
        for (var map in mapList) {
          final book = NovelBookmark.fromJson(map);
          if (book.id == '-1') continue;
          list.add(book);
        }
      } catch (e) {
        debugPrint('NovelBookmarkServices:getList - ${e.toString()}');
      }
    }
    return list;
  }

  Future<void> setListNovelList(List<Novel> list) async {
    await setList(
      list.map((e) => NovelBookmark(id: e.id, title: e.meta.title)).toList(),
    );
  }

  Future<List<Novel>> getAllNovelList() async {
    List<Novel> list = [];
    final booklList = await getAll();
    for (var bookmark in booklList) {
      final novel = await Novel.fromPath(
        PathUtil.getSourcePath(name: bookmark.id),
      );
      if (novel == null) continue;
      list.add(novel);
    }
    return list;
  }

  static File get getDBFile =>
      File(PathUtil.getLibaryPath(name: NovelBookmark.getDBName));
}
