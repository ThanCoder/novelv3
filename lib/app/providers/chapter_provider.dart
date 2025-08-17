import 'package:flutter/material.dart';
import '../novel_dir_app.dart';

class ChapterProvider extends ChangeNotifier {
  final List<Chapter> _list = [];
  Chapter? _chapter;
  String sortFieldName = 'Chapter';
  bool isSortAsc = true;
  // get
  bool isLoading = false;
  List<Chapter> get getList => _list;
  Chapter? get getCurrent => _chapter;

  Future<void> initList(String novelPath) async {
    isLoading = true;
    notifyListeners();
    _list.clear();

    final res = await ChapterServices.getList(novelPath);
    _list.addAll(res);

    isLoading = false;
    notifyListeners();

    sortList();
  }

  Future<void> setCurrent(Chapter chapter) async {
    _chapter = chapter;
    notifyListeners();
  }

  Future<void> add(Chapter chapter) async {
    _list.add(chapter);
    sortList();
    notifyListeners();
  }

  Future<void> delete(Chapter chapter) async {
    final index = _list.indexWhere((e) => e.number == chapter.number);
    if (index == -1) return;
    _list.removeAt(index);
    // del file
    await chapter.delete();
    notifyListeners();
  }

  void setSort(String field, bool isAsc) {
    sortFieldName = field;
    isSortAsc = isAsc;
    sortList();
  }

  void sortList() {
    if (sortFieldName == 'Chapter') {
      _list.sortNumber(isSmallerTop: isSortAsc);
    }
    // if (sortFieldName == 'Date') {
    //   _list.sortDate(isNewest: !isSortAsc);
    // }
    notifyListeners();
  }

  int get getLatestChapter {
    if (_list.isEmpty) return 1;
    _list.sortNumber();
    return _list.last.number;
  }
}
