import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import '../ui/novel_dir_app.dart';

class NovelProvider extends ChangeNotifier {
  final List<Novel> _list = [];
  Novel? _novel;
  int currentSortId = TSort.getDateId;
  bool isSortAsc = false;
  // get
  bool isLoading = false;
  List<Novel> get getList => _list;
  Novel? get getCurrent => _novel;

  Future<void> initList() async {
    isLoading = true;
    notifyListeners();
    _list.clear();

    final res = await NovelServices.getList();
    _list.addAll(res);

    sortList();

    isLoading = false;
    notifyListeners();
  }

  void add(Novel novel) {
    _list.insert(0, novel);
    notifyListeners();
  }

  Future<void> setCurrent(Novel novel) async {
    _novel = novel;
    notifyListeners();
  }

  Future<void> refreshCurrentNovel(String path) async {
    _novel = Novel.fromPath(path);
    notifyListeners();
  }

  void refreshNotifier() {
    notifyListeners();
  }

  Future<void> update(Novel updatedNovel, String oldTitle) async {
    try {
      _novel = updatedNovel;
      notifyListeners();

      final index = _list.indexWhere((e) => e.title == oldTitle);
      if (index == -1) return;
      _list[index] = updatedNovel;

      notifyListeners();
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString());
    }
  }

  Future<void> delete(Novel novel) async {
    try {
      final index = _list.indexWhere((e) => e.title == novel.title);
      if (index == -1) return;
      _list.removeAt(index);
      notifyListeners();

      final res = novelSeeAllScreenNotifier.value
          .where((e) => e.title != novel.title)
          .toList();
      novelSeeAllScreenNotifier.value = res;

      await novel.deleteAll();
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString(), tag: 'NovelProvider:delete');
    }
  }

  void setSort(int id, bool isAsc) {
    currentSortId = id;
    isSortAsc = isAsc;
    sortList();
  }

  void sortList() {
    if (currentSortId == TSort.getTitleId) {
      _list.sortTitle(aToZ: isSortAsc);
    }
    if (currentSortId == TSort.getDateId) {
      _list.sortDate(isNewest: !isSortAsc);
    }
    notifyListeners();
  }

  // all tags
  List<String> get getAllTags {
    final res = _list
        .expand((e) => e.getTags)
        .map((e) => e.trim())
        .toSet()
        .toList();
    res.sort((a, b) => a.compareTo(b));
    return res;
  }
}
