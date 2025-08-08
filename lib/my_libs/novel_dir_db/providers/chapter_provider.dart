import 'package:flutter/material.dart';
import '../novel_dir_db.dart';

class ChapterProvider extends ChangeNotifier {
  final List<Chapter> _list = [];
  Chapter? _chapter;
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
  }

  Future<void> setCurrent(Chapter chapter) async {
    _chapter = chapter;
    notifyListeners();
  }
}
