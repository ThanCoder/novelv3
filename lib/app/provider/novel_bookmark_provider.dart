import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/services/bookmark_services.dart';

class NovelBookmarkProvider with ChangeNotifier {
  final List<NovelModel> _list = [];
  bool isLoading = false;
  bool isExists = false;

  //get
  List<NovelModel> get getList => _list;

  Future<void> initList() async {
    _list.clear();
    final res = await BookmarkServices.instance.getNovelBookmarkList();
    _list.addAll(res);
    notifyListeners();
  }

  Future<void> add(NovelModel novel) async {
    _list.insert(0, novel);
    isExists = true;
    //db
    await BookmarkServices.instance.setNovelBookmarkList(list: _list);

    notifyListeners();
  }

  Future<void> remove(NovelModel novel) async {
    final res = _list.where((nv) => nv.title != novel.title).toList();
    _list.clear();
    _list.addAll(res);
    isExists = false;
    //db
    await BookmarkServices.instance.setNovelBookmarkList(list: _list);

    notifyListeners();
  }

  Future<void> toggle(NovelModel novel) async {
    if (checkExists(novel)) {
      await remove(novel);
    } else {
      await add(novel);
    }
  }

  bool checkExists(NovelModel novel) {
    final res = _list.where((nv) => nv.title == novel.title);
    if (res.isNotEmpty) {
      isExists = true;
      return true;
    }
    isExists = false;
    return false;
  }
}
