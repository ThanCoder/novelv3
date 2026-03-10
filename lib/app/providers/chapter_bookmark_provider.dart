import 'package:flutter/material.dart';
import 'package:novel_v3/app/providers/novel_provider.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/chapter_bookmark.dart';
import 'package:novel_v3/core/services/chapter_bookmark_services.dart';

class ChapterBookmarkProvider extends ChangeNotifier {
  final NovelProvider novelProvider;
  ChapterBookmarkProvider(this.novelProvider);

  List<ChapterBookmark> list = [];
  bool isLoading = false;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    try {
      list = await ChapterBookmarkServices.getAll(
        novelProvider.currentNovel!.path,
      );
      // sort 1 -> 9
      sortNumber();
    } catch (e) {
      debugPrint('[ChapterBookmarkProvider:e]: ${e.toString()}');
    }

    isLoading = false;
    notifyListeners();
  }

  void refershUI() {
    notifyListeners();
  }

  Future<void> update(ChapterBookmark bookmark) async {
    final index = list.indexWhere((e) => e.chapter == bookmark.chapter);
    if (index == -1) return;
    list[index] = bookmark;
    await ChapterBookmarkServices.setAll(
      list,
      novelProvider.currentNovel!.path,
    );
    notifyListeners();
  }

  Future<void> add(ChapterBookmark bookmark) async {
    list.add(bookmark);
    // sort 1 -> 9
    sortNumber();

    await ChapterBookmarkServices.setAll(
      list,
      novelProvider.currentNovel!.path,
    );
    notifyListeners();
  }

  Future<void> remove(ChapterBookmark bookmark) async {
    if (list.isEmpty) return;
    final index = list.indexWhere((e) => e.chapter == bookmark.chapter);
    if (index != -1) {
      list.removeAt(index);
    }
    await ChapterBookmarkServices.setAll(
      list,
      novelProvider.currentNovel!.path,
    );
    notifyListeners();
  }

  Future<void> removeChapter(Chapter chapter) async {
    if (list.isEmpty) return;
    final index = list.indexWhere((e) => e.chapter == chapter.number);
    if (index != -1) {
      list.removeAt(index);
    }
    await ChapterBookmarkServices.setAll(
      list,
      novelProvider.currentNovel!.path,
    );
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
    await ChapterBookmarkServices.setAll(
      list,
      novelProvider.currentNovel!.path,
    );
    notifyListeners();
  }

  bool isExistsChapter(int chapter) {
    if (list.isEmpty) return false;
    final index = list.indexWhere((e) => e.chapter == chapter);
    return index != -1;
  }

  void sortNumber() {
    list.sort((a, b) {
      if (a.chapter > b.chapter) return 1;
      if (a.chapter < b.chapter) return -1;
      return 0;
    });
  }
}
