import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/novel_bookmark_model.dart';
import 'package:novel_v3/app/utils/path_util.dart';

bool isExistsNovelBookmarkList({required NovelBookmarkModel bookmark}) {
  bool res = false;
  try {
    final resList =
        getNovelBookmarkList().where((bm) => bm.title == bookmark.title);
    res = resList.isNotEmpty;
  } catch (e) {
    debugPrint('toggleNovelBookmarkList: ${e.toString()}');
  }
  return res;
}

void toggleNovelBookmarkList({required NovelBookmarkModel bookmark}) {
  try {
    if (isExistsNovelBookmarkList(bookmark: bookmark)) {
      //remove
      removeNovelBookmarkList(bookmark: bookmark);
    } else {
      //add
      addNovelBookmarkList(bookmark: bookmark);
    }
  } catch (e) {
    debugPrint('toggleNovelBookmarkList: ${e.toString()}');
  }
}

void removeNovelBookmarkList({required NovelBookmarkModel bookmark}) {
  try {
    List<NovelBookmarkModel> list = [];
    final path = '${PathUtil.instance.getLibaryPath()}/$novelBookListName';
    final file = File(path);
    if (file.existsSync()) {
      List<dynamic> jlist = jsonDecode(file.readAsStringSync());
      list = jlist.map((map) => NovelBookmarkModel.fromMap(map)).toList();
    }

    //remove
    list = getNovelBookmarkList()
        .where((bm) => bm.title != bookmark.title)
        .toList();

    //save
    final jData = list.map((bm) => bm.toMap()).toList();
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(jData));
  } catch (e) {
    debugPrint('removeNovelBookmarkList: ${e.toString()}');
  }
}

void addNovelBookmarkList({required NovelBookmarkModel bookmark}) {
  try {
    List<NovelBookmarkModel> list = [];
    final path = '${PathUtil.instance.getLibaryPath()}/$novelBookListName';
    final file = File(path);
    if (file.existsSync()) {
      List<dynamic> jlist = jsonDecode(file.readAsStringSync());
      list = jlist.map((map) => NovelBookmarkModel.fromMap(map)).toList();
    }

    //add
    list.insert(0, bookmark);

    //save
    final jData = list.map((bm) => bm.toMap()).toList();
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(jData));
  } catch (e) {
    debugPrint('addNovelBookmarkList: ${e.toString()}');
  }
}

List<NovelBookmarkModel> getNovelBookmarkList() {
  List<NovelBookmarkModel> list = [];
  try {
    final path = '${PathUtil.instance.getLibaryPath()}/$novelBookListName';
    final file = File(path);
    if (!file.existsSync()) return list;

    if (file.existsSync()) {
      List<dynamic> jlist = jsonDecode(file.readAsStringSync());
      list = jlist.map((map) => NovelBookmarkModel.fromMap(map)).toList();
    }
  } catch (e) {
    debugPrint('getNovelBookmarkList: ${e.toString()}');
  }
  return list;
}
