import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:novel_v3/app/models/chapter_bookmark_model.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/services/index.dart';

class ChapterProvider with ChangeNotifier {
  final List<ChapterModel> _list = [];
  final List<ChapterBookmarkModel> _bookList = [];
  bool isLoading = false;
  String _novelPath = '';

  List<ChapterModel> get getList => _list;
  List<ChapterBookmarkModel> get getBookList => _bookList;
  String get getNovelPath => _novelPath;

  Future<void> initList(
      {bool isReset = false, required String novelPath}) async {
    if (!isReset && _list.isNotEmpty) {
      return;
    }
    _novelPath = novelPath;
    isLoading = true;
    notifyListeners();

    _list.clear();
    final res = await ChapterServices.instance.getList(novelPath: novelPath);
    _list.addAll(res);

    isLoading = false;
    notifyListeners();
  }

  //book mark
  Future<void> initBookList({
    bool isReset = false,
    required String bookPath,
  }) async {
    if (!isReset && _bookList.isNotEmpty) {
      return;
    }
    _novelPath = File(bookPath).parent.path;
    isLoading = true;
    notifyListeners();

    _bookList.clear();
    final res =
        await ChapterServices.instance.getBookmarkList(bookPath = bookPath);
    _bookList.addAll(res);

    isLoading = false;
    notifyListeners();
  }
}
