//chapter
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/chapter_bookmark_model.dart';

import '../models/index.dart';
import '../utils/path_util.dart';

class ChapterServices {
  static final ChapterServices instance = ChapterServices._();
  ChapterServices._();
  factory ChapterServices() => instance;
//chapter
  Future<List<ChapterModel>> getList({required String novelPath}) async {
    final completer = Completer<List<ChapterModel>>();
    try {
      final list = await Isolate.run<List<ChapterModel>>(() {
        List<ChapterModel> chapterList = [];
        final dir = Directory(novelPath);
        try {
          if (dir.existsSync()) {
            for (final file in dir.listSync()) {
              if (file.statSync().type == FileSystemEntityType.file) {
                if (int.tryParse(PathUtil.instance.getBasename(file.path)) ==
                    null) {
                  continue;
                }
                chapterList.add(ChapterModel.fromPath(file.path));
              }
            }
          }
          //sort
          chapterList.sort((a, b) => a.number.compareTo(b.number));
        } catch (e) {
          debugPrint('getList: ${e.toString()}');
        }
        return chapterList;
      });
      completer.complete(list);
    } catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  }

  Future<int> getLastChapter({required String novelPath}) async {
    int num = 0;
    try {
      final res = await getList(novelPath: novelPath);
      if (res.isNotEmpty) {
        num = int.tryParse(res.last.title) ?? 0;
      }
    } catch (e) {
      debugPrint('getLastChapterListFromPath: ${e.toString()}');
    }
    return num;
  }

  Future<int> getFirstChapter({required String novelPath}) async {
    int num = 1;
    try {
      final res = await getList(novelPath: novelPath);
      if (res.isNotEmpty) {
        num = int.tryParse(res.first.title) ?? 1;
      }
    } catch (e) {
      debugPrint('getLastChapterListFromPath: ${e.toString()}');
    }
    return num;
  }

  //book mark
  Future<List<ChapterBookmarkModel>> getBookmarkList(
      String bookmarkPath) async {
    try {
      final file = File(bookmarkPath);
      List<ChapterBookmarkModel> list = [];
      if (!await file.exists()) return [];
      List<dynamic> resList = jsonDecode(await file.readAsString());
      list = resList.map((map) => ChapterBookmarkModel.fromMap(map)).toList();
      return list;
    } catch (e) {
      debugPrint(e.toString());
    }

    return [];
  }
}
