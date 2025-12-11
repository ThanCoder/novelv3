import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_services.dart';

class NovelBookmarkProvider with ChangeNotifier {
  List<NovelBookmark> list = [];
  bool isLoading = false;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    list = await NovelBookmarkServices.getAll();
    isLoading = false;
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
    notifyListeners();
  }

  Future<void> remove(NovelBookmark bookmark) async {
    if (list.isEmpty) return;
    final index = list.indexWhere((e) => e.title == bookmark.title);
    if (index != -1) {
      list.removeAt(index);
    }
    await NovelBookmarkServices.setList(list);
    notifyListeners();
  }

  bool isExists(String title) {
    if (list.isEmpty) return false;
    final index = list.indexWhere((e) => e.title == title);
    return index != -1;
  }
}
