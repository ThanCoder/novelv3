import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/models/chapter_bookmark.dart';
import 'package:novel_v3/app/core/services/chapter_bookmark_services.dart';

class ChapterBookmarkProvider extends ChangeNotifier {
  List<ChapterBookmark> list = [];
  bool isLoading = false;
  String? currentNovelPath;

  Future<void> init(String novelPath) async {
    currentNovelPath = novelPath;
    isLoading = true;
    notifyListeners();

    list = await ChapterBookmarkServices.getAll(novelPath);
    isLoading = false;
    notifyListeners();
  }

  Future<void> add(ChapterBookmark bookmark) async {
    list.add(bookmark);
    await ChapterBookmarkServices.setAll(list, currentNovelPath!);
    notifyListeners();
  }

  Future<void> remove(ChapterBookmark bookmark) async {
    if (list.isEmpty) return;
    final index = list.indexWhere((e) => e.chapter == bookmark.chapter);
    if (index != -1) {
      list.removeAt(index);
    }
    await ChapterBookmarkServices.setAll(list, currentNovelPath!);
    notifyListeners();
  }

  Future<void> removeChapter(Chapter chapter) async {
    if (list.isEmpty) return;
    final index = list.indexWhere((e) => e.chapter == chapter.number);
    if (index != -1) {
      list.removeAt(index);
    }
    await ChapterBookmarkServices.setAll(list, currentNovelPath!);
    notifyListeners();
  }

  Future<void> toggleBookmark(ChapterBookmark bookmark) async {
    if (isExistsChapter(bookmark.chapter)) {
      final index = list.indexWhere((e) => e.chapter == bookmark.chapter);
      if (index != -1) {
        list.removeAt(index);
      }
    } else {
      // add
      list.add(bookmark);
    }
    await ChapterBookmarkServices.setAll(list, currentNovelPath!);
    notifyListeners();
  }

  bool isExistsChapter(int chapter) {
    if (list.isEmpty) return false;
    final index = list.indexWhere((e) => e.chapter == chapter);
    return index != -1;
  }
}
