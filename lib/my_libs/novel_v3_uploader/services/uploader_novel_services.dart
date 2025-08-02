import 'package:flutter/material.dart';
import '../extensions/uploader_novel_extension.dart';

import '../models/uploader_novel.dart';
import 'uploader_config_services.dart';

class UploaderNovelServices extends ChangeNotifier {
  final List<UploaderNovel> _list = [];

  List<UploaderNovel> get getList => _list;
  bool isLoading = false;

  Future<void> initList() async {
    isLoading = true;
    notifyListeners();
    _list.clear();

    final configList = await UploaderConfigServices.getListConfig();
    for (var map in configList) {
      _list.add(UploaderNovel.fromMap(map));
    }
    _list.sortDate();

    isLoading = false;
    notifyListeners();
  }

  Future<void> add(UploaderNovel novel) async {
    isLoading = true;
    notifyListeners();
    try {
      // await Future.delayed(Duration(seconds: 1));
      // check already exists title
      final findedIndex = _list.indexWhere((e) => e.title == novel.title);
      if (findedIndex != -1) {
        // ရှိနေလို့
        throw Exception('title already exists!');
      }

      _list.insert(0, novel);

      final mapList = _list.map((e) => e.toMap).toList();
      await UploaderConfigServices.setListConfig(mapList, isPrettyJson: true);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(UploaderNovel novel) async {
    isLoading = true;
    notifyListeners();
    try {
      // await Future.delayed(Duration(seconds: 1));
      // check already exists title
      final findedIndex = _list.indexWhere((e) => e.id == novel.id);
      if (findedIndex == -1) {
        // ရှိနေလို့
        throw Exception('novel not found!');
      }
      _list.removeAt(findedIndex);
      // delete content file db file
      novel.delete();

      final mapList = _list.map((e) => e.toMap).toList();
      await UploaderConfigServices.setListConfig(mapList, isPrettyJson: true);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(UploaderNovel novel) async {
    isLoading = true;
    notifyListeners();
    try {
      // await Future.delayed(Duration(seconds: 1));
      // check already exists title
      final findedIndex = _list.indexWhere((e) => e.id == novel.id);
      if (findedIndex == -1) {
        // ရှိနေလို့
        throw Exception('novel not found!');
      }
      _list[findedIndex] = novel;

      // sort
      _list.sortDate();

      final mapList = _list.map((e) => e.toMap).toList();
      await UploaderConfigServices.setListConfig(mapList, isPrettyJson: true);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
