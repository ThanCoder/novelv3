import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/chapter_bookmark_model.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class BookmarkServices {
  static final BookmarkServices instance = BookmarkServices._();
  BookmarkServices._();
  factory BookmarkServices() => instance;

  Future<List<NovelModel>> getNovelBookmarkList() async {
    try {
      final file = File(getNovelDBPath);
      if (!await file.exists()) return [];
      List<dynamic> resList = jsonDecode(await file.readAsString());
      return resList
          .map((name) =>
              NovelModel.fromPath('${PathUtil.instance.getSourcePath()}/$name'))
          .where((novel) => Directory(novel.path).existsSync())
          .toList();
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  Future<void> setNovelBookmarkList({required List<NovelModel> list}) async {
    try {
      final file = File(getNovelDBPath);
      final nameList = list.map((nv) => nv.title).toList();
      await file
          .writeAsString(const JsonEncoder.withIndent(' ').convert(nameList));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //chapter
  Future<List<ChapterBookmarkModel>> getChapterBookmarkList(
      String novelPath) async {
    try {
      final file = File(getChapterDBPath(novelPath));
      if (!await file.exists()) return [];
      List<dynamic> resList = jsonDecode(await file.readAsString());
      final list = resList
          .where((map) => File('$novelPath/${map['chapter']}').existsSync())
          .map((map) => ChapterBookmarkModel.fromMap(map))
          .toList();
      //sort
      list.sort((a, b) => a.chapter.compareTo(b.chapter));
      return list;
    } catch (e) {
      debugPrint('getChapterBookmarkList: ${e.toString()}');
    }
    return [];
  }

  Future<void> setChapterBookmarkList(
    String novelPath, {
    required List<ChapterBookmarkModel> list,
  }) async {
    try {
      final file = File(getChapterDBPath(novelPath));
      final nameList = list.map((bm) => bm.toMap()).toList();
      await file
          .writeAsString(const JsonEncoder.withIndent(' ').convert(nameList));
    } catch (e) {
      debugPrint('setChapterBookmarkList: ${e.toString()}');
    }
  }

  String get getNovelDBPath =>
      '${PathUtil.instance.getLibaryPath()}/$novelBookListName';

  String getChapterDBPath(String novelPath) =>
      '$novelPath/$chapterBookMarkListName';
}
