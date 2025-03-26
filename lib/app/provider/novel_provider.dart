import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';

import '../services/index.dart';

class NovelProvider with ChangeNotifier {
  final List<NovelModel> _list = [];
  bool _isLoading = false;
  NovelModel? _currentNovel;

  List<NovelModel> get getList => _list;
  NovelModel? get getNovel => _currentNovel;
  bool get isLoading => _isLoading;

  void initList({bool isReset = false}) async {
    try {
      if (_list.isNotEmpty && !isReset) {
        return;
      }
      _isLoading = true;
      notifyListeners();

      final res = await getNovelListFromPathIsolate();
      _list.clear();
      _list.addAll(res);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('initList: ${e.toString()}');
    }
  }

  void setCurrentNovel({required String novelSourcePath}) {
    _isLoading = true;
    notifyListeners();
    _currentNovel = NovelModel.fromPath(novelSourcePath, isFullInfo: true);
    currentNovelNotifier.value = _currentNovel;

    _isLoading = false;
    notifyListeners();
  }

  void add({required NovelModel novel}) async {
    try {} catch (e) {
      debugPrint('add: ${e.toString()}');
    }
  }

  Future<void> update(
      {required NovelModel novel, required String oldTitle}) async {
    try {
      await updateNovel(oldNovelTitle: oldTitle, novel: novel);
      //update ui
      _currentNovel = novel;
      currentNovelNotifier.value = novel;
      notifyListeners();
      initList();
    } catch (e) {
      debugPrint('update: ${e.toString()}');
    }
  }

  void delete() async {
    try {} catch (e) {
      debugPrint('delete: ${e.toString()}');
    }
  }
}
