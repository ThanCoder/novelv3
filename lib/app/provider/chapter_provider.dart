import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';

import '../services/index.dart';

class ChapterProvider with ChangeNotifier {
  final List<ChapterModel> _list = [];
  bool _isLoading = false;

  List<ChapterModel> get getList => _list;
  bool get isLoading => _isLoading;

  Future<void> initList() async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await ChapterServices.instance.getChapterListFromPathIsolate(
          novelSourcePath: currentNovelNotifier.value!.path);

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
    try {
      _list.add(chapter);
      notifyListeners();
    } catch (e) {
      debugPrint('add: ${e.toString()}');
    }
  }

  void update({required ChapterModel chapter}) async {
    try {
      final res = _list.map((ch) {
        if (ch.title == chapter.title) {
          ch = chapter;
        }
        return ch;
      }).toList();
      _list.clear();
      _list.addAll(res);

      notifyListeners();
    } catch (e) {
      debugPrint('update: ${e.toString()}');
    }
  }

  void delete({required ChapterModel chapter}) async {
    try {
      final res = _list.where((ch) => ch.title != chapter.title).toList();
      _list.clear();
      _list.addAll(res);

      notifyListeners();
    } catch (e) {
      debugPrint('delete: ${e.toString()}');
    }
  }

  Future<int> getFirstChapterNumber() async {
    _isLoading = true;
    notifyListeners();

    final res = await ChapterServices.instance.getFirstChapterListFromPath(
      novelSourcePath: currentNovelNotifier.value!.path,
    );
    _isLoading = false;
    notifyListeners();
    return res;
  }

  Future<int> getLastChapterNumber() async {
    _isLoading = true;
    notifyListeners();

    final res = await ChapterServices.instance.getLastChapterListFromPath(
      novelSourcePath: currentNovelNotifier.value!.path,
    );
    _isLoading = false;
    notifyListeners();
    return res;
  }
}
