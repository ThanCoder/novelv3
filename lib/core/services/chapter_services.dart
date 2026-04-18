// ignore_for_file: unused_element

import 'package:flutter/foundation.dart';
import 'package:novel_v3/core/databases/chapter_db.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';

class _ChapterServices {
  _ChapterServices._();
  static final instance = _ChapterServices._();
  factory _ChapterServices() => instance;

  Future<void> clearAll() async {
    await ChapterDB.clearAll();
  }

  Future<void> clear(String novelId) async {
    await ChapterDB.clear(novelId);
  }

  Future<List<Chapter>> getAll({
    required String novelId,
    bool runInBackground = true,
  }) async {
    if (runInBackground) {
      final novelPath = PathUtil.getSourcePath(name: novelId);
      return await compute(getAllChapterInBackground, novelPath);
    }
    return await ChapterDB.getAll(novelId);
  }

  Future<String?> getContent(int chapterNumber, String novelId) async {
    final res = await ChapterDB.getContent(chapterNumber, novelId);
    if (res == null) return null;
    return res.content;
  }

  Future<void> update(Chapter chapter, {required String novelId}) async {
    await ChapterDB.update(chapter, novelId: novelId);
  }

  Future<int> add(Chapter chapter, {required String novelId}) async {
    return await ChapterDB.add(chapter, novelId: novelId);
  }

  Future<void> deleteAllById(List<int> ids, {required String novelId}) async {
    await ChapterDB.deleteAllById(ids, novelId: novelId);
  }

  Future<void> delete(Chapter chapter, {required String novelId}) async {
    await ChapterDB.delete(chapter, novelId: novelId);
  }

  Future<void> deleteAll({required String novelId}) async {
    await ChapterDB.deleteAll(novelId: novelId);
  }

  Future<void> deleteDBFile(String novelId) async {
    await ChapterDB.deleteDBFile(novelId);
  }
}
