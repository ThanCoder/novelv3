import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';

import '../services/index.dart';

class ChapterProvider with ChangeNotifier {
  final List<ChapterModel> _list = [];
  bool _isLoading = false;
  int firstChapter = 1;
  int lastChapter = 0;

  List<ChapterModel> get getList => _list;
  bool get isLoading => _isLoading;

  Future<void> initList() async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await getChapterListFromPathIsolate(
          novelSourcePath: currentNovelNotifier.value!.path);
      if (res.isNotEmpty) {
        firstChapter = int.tryParse(res.first.title) ?? 1;
        lastChapter = int.tryParse(res.last.title) ?? 0;
      }

      _list.clear();
      _list.addAll(res);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('initList: ${e.toString()}');
    }
  }

  void reversed() {
    final res = _list.reversed.toList();
    _list.clear();
    _list.addAll(res);
    notifyListeners();
  }

  void add({required ChapterModel chapter}) async {
    try {} catch (e) {
      debugPrint('add: ${e.toString()}');
    }
  }

  void update({required ChapterModel chapter}) async {
    try {} catch (e) {
      debugPrint('update: ${e.toString()}');
    }
  }

  void delete() async {
    try {} catch (e) {
      debugPrint('delete: ${e.toString()}');
    }
  }
}
