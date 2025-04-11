import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/services/novel_services.dart';

class NovelProvider with ChangeNotifier {
  final List<NovelModel> _list = [];
  bool isLoading = false;
  NovelModel? _novel;

  List<NovelModel> get getList => _list;
  NovelModel? get getCurrent => _novel;

  Future<void> initList({bool isReset = false}) async {
    if (!isReset && _list.isNotEmpty) {
      return;
    }
    isLoading = true;
    notifyListeners();

    _list.clear();
    final res = await NovelServices.instance.getList();
    _list.addAll(res);

    isLoading = false;
    notifyListeners();
  }

  Future<void> setCurrent(NovelModel novel) async {
    _novel = NovelModel.fromPath(novel.path, isFullInfo: true);
    notifyListeners();
  }
}
