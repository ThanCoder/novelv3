import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineNovelProvider with ChangeNotifier {
  late final _client = Supabase.instance.client;
  final List<OnlineNovelModel> _list = [];
  bool _isLoading = false;

  List<OnlineNovelModel> get getList => _list;
  bool get isLoading => _isLoading;

  Future<void> initList() async {
    try {
      _isLoading = true;
      notifyListeners();

      final res = await _client.from('novel').select().eq('is_publish', true);
      var list = res.map((map) => OnlineNovelModel.fromMap(map)).toList();
      //sort
      list.sort((a, b) {
        return a.createdAt!.millisecondsSinceEpoch
            .compareTo(b.createdAt!.millisecondsSinceEpoch);
      });
      list = list.reversed.toList();
      //add all
      _list.clear();
      _list.addAll(list);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('initList: ${e.toString()}');
    }
  }

  Future<void> add({required OnlineNovelModel novel}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _client.from(OnlineNovelModel.dbName).insert(novel.toMap());

      _isLoading = false;
      notifyListeners();
      await initList();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('add: ${e.toString()}');
    }
  }

  Future<void> delete({required OnlineNovelModel novel}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _client.from(OnlineNovelModel.dbName).delete().eq('id', novel.id!);
      var list = _list.where((nv) => nv.id != novel.id).toList();
      _list.clear();
      _list.addAll(list);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('add: ${e.toString()}');
    }
  }

  Future<void> update({required OnlineNovelModel novel}) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _client
          .from(OnlineNovelModel.dbName)
          .update(novel.toMap())
          .eq('id', novel.id!);

      _isLoading = false;
      notifyListeners();
      await initList();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('update: ${e.toString()}');
    }
  }
}
