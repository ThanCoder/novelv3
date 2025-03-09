import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/index.dart';

class ChapterBookmarkServices {
  static final ChapterBookmarkServices instance = ChapterBookmarkServices._();
  ChapterBookmarkServices._();
  factory ChapterBookmarkServices() => instance;

  //book mark
  Future<List<ChapterBookMarkModel>> getList({
    required String novelPath,
  }) async {
    List<ChapterBookMarkModel> list = [];
    try {
      final file = File('$novelPath/$chapterBookMarkListName');
      if (!await file.exists()) return [];

      List<dynamic> jlist = jsonDecode(await file.readAsString());
      list = jlist.map((json) => ChapterBookMarkModel.fromJson(json)).toList();

      //sort
      list.sort((a, b) {
        int ac = int.tryParse(a.chapter) ?? 0;
        int bc = int.tryParse(b.chapter) ?? 0;
        return ac.compareTo(bc);
      });
    } catch (e) {
      debugPrint('getBookMarkList: ${e.toString()}');
    }
    return list;
  }

  Future<void> setList({
    required String novelPath,
    required List<ChapterBookMarkModel> list,
  }) async {
    final file = File('$novelPath/$chapterBookMarkListName');
    final data = jsonEncode(list.map((bm) => bm.toMap()).toList());
    await file.writeAsString(data);
  }

  Future<void> toggle({
    required String novelPath,
    required ChapterBookMarkModel bookmark,
  }) async {
    if (await exists(novelPath: novelPath, chapter: bookmark.chapter)) {
      await remove(novelPath: novelPath, chapter: bookmark.chapter);
    } else {
      await add(novelPath: novelPath, bookmark: bookmark);
    }
  }

  Future<bool> exists({
    required String novelPath,
    required String chapter,
  }) async {
    bool res = false;
    // await Future.delayed(const Duration(seconds: 2));

    final list = await getList(novelPath: novelPath);
    if (list.isEmpty) return false;
    res = list.any((bm) => bm.chapter == bm.chapter);
    return res;
  }

  Future<void> remove({
    required String novelPath,
    required String chapter,
  }) async {
    var list = await getList(novelPath: novelPath);
    list = list.where((bm) => bm.chapter != chapter).toList();

    final data = list.map((bm) => bm.toMap()).toList();
    final file = File('$novelPath/$chapterBookMarkListName');
    if (!await file.exists()) return;
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> add({
    required String novelPath,
    required ChapterBookMarkModel bookmark,
  }) async {
    var list = await getList(novelPath: novelPath);
    list.add(bookmark);

    final data = list.map((bm) => bm.toMap()).toList();
    final file = File('$novelPath/$chapterBookMarkListName');
    if (!await file.exists()) return;
    await file.writeAsString(jsonEncode(data));
  }
}
