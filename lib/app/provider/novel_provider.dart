import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/services/novel_isolate_services.dart';

class NovelProvider with ChangeNotifier {
  final List<NovelModel> _list = [];
  bool _isLoading = false;

  List<NovelModel> get getList => _list;
  bool get isLoading => _isLoading;

  void initList() async {
    try {
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

  void add({required NovelModel novel}) async {
    try {} catch (e) {
      debugPrint('add: ${e.toString()}');
    }
  }

  void update({required NovelModel novel}) async {
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
