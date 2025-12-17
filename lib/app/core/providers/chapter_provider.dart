import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/extensions/chapter_extension.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/services/chapter_services.dart';
import 'package:t_widgets/t_widgets.dart';

class ChapterProvider extends ChangeNotifier {
  List<Chapter> list = [];
  bool isLoading = false;
  String? currentNovelPath;

  Future<void> init(String novelPath, {bool isUsedCache = true}) async {
    if (isUsedCache && list.isNotEmpty && novelPath == currentNovelPath) return;

    isLoading = true;
    notifyListeners();
    currentNovelPath = novelPath;
    list = await ChapterServices.getAll(novelPath);

    sort(currentSortId, sortAsc);

    isLoading = false;
    notifyListeners();
  }

  Future<void> add(Chapter chapter) async {
    chapter = chapter.copyWith(novelPath: currentNovelPath);
    list.add(chapter);
    await ChapterServices.setChapter(chapter);
    notifyListeners();
  }

  Future<void> delete(Chapter chapter) async {
    final index = list.indexWhere((e) => e.number == chapter.number);
    if (index == -1) return;
    list.removeAt(index);
    await ChapterServices.delete(chapter);
    notifyListeners();
  }

  bool isExistsNumber(int number) {
    final index = list.indexWhere((e) => e.number == number);
    return index != -1;
  }

  Future<String?> getContent(int chapterNumber, {String? novelPath}) async {
    final content = await ChapterServices.getContent(
      chapterNumber,
      novelPath ?? currentNovelPath!,
    );
    currentNovelPath = novelPath;
    return content;
  }

  Future<void> setChapter(Chapter chapter) async {
    int index = list.indexWhere((e) => e.number == chapter.number);
    if (index == -1) {
      await add(chapter);
      return;
    }
    list[index] = chapter;
    await ChapterServices.setChapter(chapter);
    notifyListeners();
  }

  int get getLatestChapter {
    list.sortChapterNumber(isSort: true);
    return list.isEmpty ? 0 : list.last.number;
  }

  // sort
  bool sortAsc = true;
  int currentSortId = 1;
  List<TSort> sortList = [
    TSort(id: 1, title: 'Number', ascTitle: 'Smallest', descTitle: 'Biggest'),
  ];

  void sort(int currentId, bool isAsc) {
    sortAsc = isAsc;
    currentSortId = currentId;
    if (currentSortId == 1) {
      // size
      list.sortChapterNumber(isSort: sortAsc);
    }
    notifyListeners();
  }
}
