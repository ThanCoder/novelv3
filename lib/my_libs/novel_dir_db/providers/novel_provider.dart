import 'package:flutter/material.dart';
import '../novel_dir_db.dart';

class NovelProvider extends ChangeNotifier {
  final List<Novel> _list = [];
  bool isLoading = false;
  List<Novel> get getList => _list;

  Future<void> initList() async {
    isLoading = true;
    notifyListeners();
    _list.clear();

    final res = await NovelServices.getList();
    _list.addAll(res);

    isLoading = false;
    notifyListeners();
  }
}
