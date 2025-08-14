import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/sort_dialog_v1.0.0/sort_type.dart';
import '../novel_dir_app.dart';

class NovelProvider extends ChangeNotifier {
  final List<Novel> _list = [];
  Novel? _novel;
  SortType sortType = SortType(title: 'date', isAsc: false);
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

    sortList(sortType);

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

      final res = novelSeeAllScreenNotifier.value
          .where((e) => e.title != novel.title)
          .toList();
      novelSeeAllScreenNotifier.value = res;

      await novel.deleteAll();
      notifyListeners();
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString(), tag: 'NovelProvider:delete');
    }
  }

  void sortList(SortType sort) {
    sortType = sort;
    if (sort.title == 'title') {
      _list.sort((a, b) {
        if (sort.isAsc) {
          return a.title.compareTo(b.title);
        } else {
          return b.title.compareTo(a.title);
        }
      });
    }
    if (sort.title == 'date') {
      _list.sortDate(isNewest: !sort.isAsc);
    }
    notifyListeners();
  }

  // all tags
  List<String> get getAllTags {
    final res = _list.expand((e) => e.getTags).toSet().toList();
    return res;
  }
}
