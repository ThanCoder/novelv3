import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_services.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';

class NovelBookmarkProvider with ChangeNotifier {
  List<NovelBookmark> list = [];
  List<Novel> novelList = [];
  bool isLoading = false;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    list = await NovelBookmarkServices.getAll();

    await parseNovelList();

    isLoading = false;
    notifyListeners();
  }

  Future<void> parseNovelList() async {
    novelList.clear();
    for (var bookmark in list) {
      final novel = await Novel.fromPath(
        PathUtil.getSourcePath(name: bookmark.title),
      );
      if (novel == null) continue;
      novelList.add(novel);
    }
    notifyListeners();
  }

  Future<void> toggle(NovelBookmark bookmark) async {
    if (isExists(bookmark.title)) {
      await remove(bookmark);
    } else {
      await add(bookmark);
    }
  }

  Future<void> add(NovelBookmark bookmark) async {
    list.insert(0, bookmark);
    await NovelBookmarkServices.setList(list);
    await parseNovelList();
    notifyListeners();
  }

  Future<void> remove(NovelBookmark bookmark) async {
    if (list.isEmpty) return;
    final index = list.indexWhere((e) => e.title == bookmark.title);
    if (index != -1) {
      list.removeAt(index);
    }
    await parseNovelList();
    await NovelBookmarkServices.setList(list);
    notifyListeners();
  }

  bool isExists(String title) {
    if (list.isEmpty) return false;
    final index = list.indexWhere((e) => e.title == title);
    return index != -1;
  }
}
