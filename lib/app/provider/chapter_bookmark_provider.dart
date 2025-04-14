import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/chapter_bookmark_model.dart';
import 'package:novel_v3/app/services/bookmark_services.dart';

class ChapterBookmarkProvider with ChangeNotifier {
  final List<ChapterBookmarkModel> _list = [];
  bool isLoading = false;

  //get
  List<ChapterBookmarkModel> get getList => _list;

  Future<void> initList(String novelPath) async {
    _list.clear();
    final res =
        await BookmarkServices.instance.getChapterBookmarkList(novelPath);
    _list.addAll(res);
    notifyListeners();
  }

  Future<void> add(String novelPath, ChapterBookmarkModel book) async {
    _list.insert(0, book);
    //db
    await BookmarkServices.instance
        .setChapterBookmarkList(novelPath, list: _list);
    notifyListeners();
  }

  Future<void> remove(String novelPath, ChapterBookmarkModel book) async {
    final res = _list.where((bm) => bm.chapter != book.chapter).toList();
    _list.clear();
    _list.addAll(res);
    //db
    await BookmarkServices.instance
        .setChapterBookmarkList(novelPath, list: _list);

    notifyListeners();
  }

  Future<void> toggle(String novelPath, ChapterBookmarkModel book) async {
    if (isExists(book.chapter)) {
      await remove(novelPath, book);
    } else {
      await add(novelPath, book);
    }
  }

  bool isExists(int chapterNumber) {
    final res = _list.where((book) => book.chapter == chapterNumber);
    if (res.isNotEmpty) return true;
    return false;
  }
}
