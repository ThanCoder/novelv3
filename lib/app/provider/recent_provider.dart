import 'package:flutter/widgets.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/services/recent_services.dart';

class RecentProvider with ChangeNotifier {
  final List<NovelModel> _list = [];

  //get
  List<NovelModel> get getList => _list;

  Future<void> initList() async {
    _list.clear();
    final res = await RecentServices.getList();
    _list.addAll(res);
    notifyListeners();
  }

  Future<void> add(NovelModel novel) async {
    if (_list.isEmpty) {
      _list.insert(0, novel);
      await RecentServices.setList(list: _list);
      notifyListeners();
      return;
    }
    //ထပ်နေလား စစ်မယ်
    //ရှိနေရင်
    if (_list.isNotEmpty && _list.first.title != novel.title) {
      _list.insert(0, novel);
      await RecentServices.setList(list: _list);
      notifyListeners();
    }

    //db
  }
}
