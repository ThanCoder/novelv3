import 'package:flutter/material.dart';
import '../novel_dir_app.dart';

class NovelProvider extends ChangeNotifier {
  final List<Novel> _list = [];
  Novel? _novel;
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

    // sort
    _list.sortDate();

    isLoading = false;
    notifyListeners();
  }

  Future<void> setCurrent(Novel novel) async {
    _novel = novel;
    notifyListeners();
  }

  Future<void> update(Novel novel, String oldTitle) async {
    try {
      final index = _list.indexWhere((e) => e.title == oldTitle);
      if (index == -1) return;
      _list[index] = novel;

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

      await novel.deleteAll();
      notifyListeners();
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString());
    }
  }

  // all tags
  List<String> get getAllTags {
    final res = _list.expand((e) => e.getTags).toSet().toList();
    return res;
  }
}
