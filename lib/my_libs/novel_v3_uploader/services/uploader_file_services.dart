import 'package:flutter/cupertino.dart';
import '../extensions/uploader_file_extension.dart';
import '../models/uploader_file.dart';

import 'uploader_config_services.dart';

class UploaderFileServices extends ChangeNotifier {
  static String getDBName(String novelId) {
    return 'content_db/$novelId.db.json';
  }

  final List<UploaderFile> _list = [];

  List<UploaderFile> get getList => _list;
  bool isLoading = false;

  Future<void> initList({required String novelId}) async {
    isLoading = true;
    notifyListeners();
    _list.clear();

    final configList = await UploaderConfigServices.getListConfig(
      dbName: getDBName(novelId),
    );
    for (var map in configList) {
      _list.add(UploaderFile.fromMap(map));
    }
    _list.sortDate();

    isLoading = false;
    notifyListeners();
  }

  Future<void> add(UploaderFile file) async {
    isLoading = true;
    notifyListeners();
    try {
      _list.insert(0, file);

      final mapList = _list.map((e) => e.toMap).toList();
      await UploaderConfigServices.setListConfig(
        dbName: getDBName(file.novelId),
        mapList,
        isPrettyJson: true,
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(UploaderFile file) async {
    // isLoading = true;
    // notifyListeners();
    try {
      // await Future.delayed(Duration(seconds: 1));
      // check already exists title
      final findedIndex = _list.indexWhere((e) => e.name == file.name);
      if (findedIndex == -1) {
        // ရှိနေလို့
        throw Exception('file not found!');
      }
      _list.removeAt(findedIndex);

      final mapList = _list.map((e) => e.toMap).toList();
      await UploaderConfigServices.setListConfig(
        dbName: getDBName(file.novelId),
        mapList,
        isPrettyJson: true,
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      // isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(UploaderFile file) async {
    isLoading = true;
    notifyListeners();
    try {
      // await Future.delayed(Duration(seconds: 1));
      // check already exists title
      final findedIndex = _list.indexWhere((e) => e.name == file.name);
      if (findedIndex == -1) {
        // ရှိနေလို့
        throw Exception('file not found!');
      }
      _list[findedIndex] = file;

      // sort
      _list.sortDate();

      final mapList = _list.map((e) => e.toMap).toList();
      await UploaderConfigServices.setListConfig(
        dbName: getDBName(file.novelId),
        mapList,
        isPrettyJson: true,
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
