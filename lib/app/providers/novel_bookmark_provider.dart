import 'package:flutter/material.dart';
import 'package:novel_v3/app/services/novel_bookmark_services.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import '../ui/novel_dir_app.dart';

class NovelBookmarkProvider extends ChangeNotifier {
  final List<Novel> _list = [];
  // get
  bool isLoading = false;
  List<Novel> get getList => _list;

  Future<void> initList() async {
    isLoading = true;
    notifyListeners();
    _list.clear();

    final res = await NovelBookmarkServices.getList();
    final novelList = res
        .map((e) => Novel.fromPath('${PathUtil.getSourcePath()}/$e'))
        .toList();
    _list.addAll(novelList);

    // await Future.delayed(Duration(seconds: 3));
    isLoading = false;
    notifyListeners();
  }
}
