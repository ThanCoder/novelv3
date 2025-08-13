import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/sort_dialog_v1.0.0/sort_type.dart';
import '../novel_dir_app.dart';

class ChapterProvider extends ChangeNotifier {
  final List<Chapter> _list = [];
  Chapter? _chapter;
  SortType sortType = SortType(title: 'chatper', isAsc: true);
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
    sortList(sortType);
  }

  Future<void> setCurrent(Chapter chapter) async {
    _chapter = chapter;
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

  void sortList(SortType type) {
    sortType = type;
    if (type.title == 'chapter') {
      _list.sort((a, b) {
        if (type.isAsc) {
          if (a.number > b.number) return 1;
          if (a.number < b.number) return -1;
        } else {
          // desc
          if (a.number > b.number) return -1;
          if (a.number < b.number) return 1;
        }
        return 0;
      });
    }
    notifyListeners();
  }
}
