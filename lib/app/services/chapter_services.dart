//chapter
import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';

import '../models/index.dart';
import '../utils/path_util.dart';

class ChapterServices {
  static final ChapterServices instance = ChapterServices._();
  ChapterServices._();
  factory ChapterServices() => instance;
//chapter
  Future<List<ChapterModel>> getChapterListFromPathIsolate(
      {required String novelSourcePath}) async {
    final completer = Completer<List<ChapterModel>>();
    try {
      final list = await Isolate.run<List<ChapterModel>>(() {
        List<ChapterModel> chapterList = [];
        final dir = Directory(novelSourcePath);
        try {
          if (dir.existsSync()) {
            for (final file in dir.listSync()) {
              if (file.statSync().type == FileSystemEntityType.file) {
                if (int.tryParse(getBasename(file.path)) == null) continue;
                chapterList.add(
                  ChapterModel.fromFile(
                    File(file.path),
                  ),
                );
              }
            }
          }
          //sort
          chapterList.sort((a, b) {
            int an = int.tryParse(a.title) == null ? 0 : int.parse(a.title);
            int bn = int.tryParse(b.title) == null ? 0 : int.parse(b.title);
            return an.compareTo(bn);
          });
        } catch (e) {
          debugPrint('getChapterListFromPathIsolate: ${e.toString()}');
        }
        return chapterList;
      });
      completer.complete(list);
    } catch (e) {
      completer.completeError(e);
    }
    return completer.future;
  }

  Future<int> getLastChapterListFromPath(
      {required String novelSourcePath}) async {
    int num = 0;
    try {
      final res =
          await getChapterListFromPathIsolate(novelSourcePath: novelSourcePath);
      if (res.isNotEmpty) {
        num = int.tryParse(res.last.title) ?? 0;
      }
    } catch (e) {
      debugPrint('getLastChapterListFromPath: ${e.toString()}');
    }
    return num;
  }

  Future<int> getFirstChapterListFromPath(
      {required String novelSourcePath}) async {
    int num = 1;
    try {
      final res =
          await getChapterListFromPathIsolate(novelSourcePath: novelSourcePath);
      if (res.isNotEmpty) {
        num = int.tryParse(res.first.title) ?? 1;
      }
    } catch (e) {
      debugPrint('getLastChapterListFromPath: ${e.toString()}');
    }
    return num;
  }
}
