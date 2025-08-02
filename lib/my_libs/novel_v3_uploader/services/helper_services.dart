import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'index.dart';
import '../models/index.dart';

class HelperServices extends ChangeNotifier {
  final List<HelperFile> _list = [];

  List<HelperFile> get getList => _list;
  bool isLoading = false;

  Future<void> initLocalList() async {
    isLoading = true;
    notifyListeners();
    _list.clear();

    final res = await HelperServices.getLocalList();

    _list.addAll(res);
    // _list.sortDate();

    isLoading = false;
    notifyListeners();
  }

  //online
  Future<void> initOnlineList() async {
    isLoading = true;
    notifyListeners();
    _list.clear();

    final res = await HelperServices.getOnlineList();

    _list.addAll(res);
    // _list.sortDate();

    isLoading = false;
    notifyListeners();
  }

  // crud
  Future<void> add(HelperFile helper) async {
    isLoading = true;
    notifyListeners();
    try {

      _list.insert(0, helper);

      await HelperServices.setLocalList(_list);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> update(HelperFile helper) async {
    isLoading = true;
    notifyListeners();
    try {
      // check already exists title
      final findedIndex = _list.indexWhere((e) => e.id == helper.id);
      if (findedIndex == -1) {
        // ရှိနေလို့
        throw Exception('helper not found!');
      }
      _list[findedIndex] = helper;

      // sort
      // _list.sortDate();

      await HelperServices.setLocalList(_list);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(HelperFile helper) async {
    isLoading = true;
    notifyListeners();
    try {
      // await Future.delayed(Duration(seconds: 1));
      // check already exists title
      final findedIndex = _list.indexWhere((e) => e.id == helper.id);
      if (findedIndex == -1) {
        // ရှိနေလို့
        throw Exception('helper not found!');
      }
      _list.removeAt(findedIndex);
      // delete content file db file
      // helper.delete();

      await HelperServices.setLocalList(_list);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // static

  static Future<void> setLocalList(List<HelperFile> list) async {
    try {
      final path = ServerFileServices.getHelperDBLocalPath('v3.main');
      final file = File(path);
      final mapList = list.map((e) => e.toMap).toList();
      final jsonStr = JsonEncoder.withIndent(' ').convert(mapList);
      await file.writeAsString(jsonStr);
    } catch (e) {
      OnlineNovelServices.instance.showLog(e.toString());
    }
  }

  static Future<List<HelperFile>> getLocalList() async {
    List<HelperFile> list = [];
    try {
      final path = ServerFileServices.getHelperDBLocalPath('v3.main');
      final file = File(path);
      if (!file.existsSync()) return list;

      List<dynamic> resList = jsonDecode(file.readAsStringSync());
      list = resList.map((map) => HelperFile.fromMap(map)).toList();
    } catch (e) {
      OnlineNovelServices.instance.showLog(e.toString());
    }
    return list;
  }

  static Future<List<HelperFile>> getOnlineList() async {
    List<HelperFile> list = [];
    try {
      final url = ServerFileServices.getHelperDBUrl('v3.main.db.json');
      final json = await OnlineNovelServices.instance.onDownloadJson!(url);
      List<dynamic> resList = jsonDecode(json);
      list = resList.map((map) => HelperFile.fromMap(map)).toList();
    } catch (e) {
      OnlineNovelServices.instance.showLog(e.toString());
    }
    return list;
  }
}
