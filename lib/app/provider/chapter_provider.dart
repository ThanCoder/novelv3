import 'package:flutter/widgets.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/services/index.dart';

class ChapterProvider with ChangeNotifier {
  final List<ChapterModel> _list = [];
  bool isLoading = false;
  String _novelPath = '';

  List<ChapterModel> get getList => _list;
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
}
