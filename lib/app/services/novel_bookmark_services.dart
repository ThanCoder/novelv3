import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class NovelBookmarkServices {
  static final NovelBookmarkServices instance = NovelBookmarkServices._();
  NovelBookmarkServices._();
  factory NovelBookmarkServices() => instance;

  Future<bool> isExists(NovelModel novel) async {
    bool res = false;
    try {
      final list = await getList();
      return list.any((nv) => nv.title == novel.title);
    } catch (e) {
      debugPrint('isExists: ${e.toString()}');
    }
    return res;
  }

  Future<void> toggle({required NovelModel novel}) async {
    try {
      if (await isExists(novel)) {
        //remove
        await remove(novel);
      } else {
        //add
        await add(novel);
      }
    } catch (e) {
      debugPrint('toggle: ${e.toString()}');
    }
  }

  Future<void> remove(NovelModel novel) async {
    try {
      List<NovelModel> list = await getList();
      //remove
      list = list.where((bm) => bm.title != novel.title).toList();

      //save
      final jData = list.map((bm) => bm.toMap()).toList();
      final file = File(getPath());
      file.writeAsStringSync(jsonEncode(jData));
    } catch (e) {
      debugPrint('remove: ${e.toString()}');
    }
  }

  Future<void> add(NovelModel novel) async {
    try {
      List<NovelModel> list = await getList();
      //add
      list.insert(0, novel);
      //save
      final jData = list.map((bm) => bm.toMap()).toList();
      final file = File(getPath());
      file.writeAsStringSync(jsonEncode(jData));
    } catch (e) {
      debugPrint('add: ${e.toString()}');
    }
  }

  Future<List<NovelModel>> getList() async {
    List<NovelModel> list = [];
    try {
      final file = File(getPath());
      if (!await file.exists()) return list;

      if (await file.exists()) {
        try {
          List<dynamic> jlist = jsonDecode(file.readAsStringSync());
          list = jlist.map((map) => NovelModel.fromMap(map)).toList();
        } catch (e) {
          file.deleteSync();
        }
      }
    } catch (e) {
      debugPrint('getList: ${e.toString()}');
    }
    return list;
  }

  String getPath() {
    return '${PathUtil.instance.getLibaryPath()}/$novelBookListName';
  }
}
