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

  void refershUI() {
    sort(currentSortId, sortAsc);
    notifyListeners();
  }

  Future<void> add(Chapter chapter) async {
    final autoId = await ChapterServices.add(chapter);
    chapter = chapter.copyWith(autoId: autoId, novelPath: currentNovelPath);
    chapter.content = null;
    list.add(chapter);

    sort(currentSortId, sortAsc);
    notifyListeners();
  }

  Future<void> delete(Chapter chapter) async {
    final index = list.indexWhere((e) => e.number == chapter.number);
    if (index == -1) return;
    list.removeAt(index);
    await ChapterServices.delete(chapter);
    notifyListeners();
  }

  Future<void> deleteAll() async {
    isLoading = true;
    notifyListeners();

    list.clear();
    await ChapterServices.deleteAll();
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteDBFile(String novelPath) async {
    isLoading = true;
    notifyListeners();

    list.clear();
    await ChapterServices.deleteDBFile(novelPath);
    isLoading = false;
    notifyListeners();
  }

  Chapter? getOne(bool Function(Chapter chapter) test) {
    final index = list.indexWhere((e) => test(e));
    if (index == -1) return null;
    return list[index];
  }

  bool isExistsNumber(int number) {
    final index = list.indexWhere((e) => e.number == number);
    return index != -1;
  }

  Future<String?> getContent(int chapterNumber, {String? novelPath}) async {
    try {
      final content = await ChapterServices.getContent(
        chapterNumber,
        novelPath ?? currentNovelPath!,
      );
      currentNovelPath = novelPath;
      return content;
    } catch (e) {
      debugPrint('[ChapterProvider:getContent]: ${e.toString()}');
      return null;
    }
  }

  Future<void> update(Chapter chapter) async {
    int index = list.indexWhere((e) => e.number == chapter.number);
    if (index == -1) {
      return;
    }
    await ChapterServices.update(chapter);
    chapter.content = null;
    list[index] = chapter;
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
    TSort(id: 1, title: 'Number', ascTitle: 'Smallest', descTitle: 'Largest'),
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
