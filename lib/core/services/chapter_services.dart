import 'package:flutter/foundation.dart';
import 'package:novel_v3/core/databases/chapter_db.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';

class ChapterServices {
  ChapterServices._();
  static final instance = ChapterServices._();
  factory ChapterServices() => instance;

  Future<List<Chapter>> getAll(
    String novelId, {
    bool runInBackground = true,
  }) async {
    if (runInBackground) {
      final novelPath = PathUtil.getSourcePath(name: novelId);
      return await compute(getAllChapterInBackground, novelPath);
    }
    return await ChapterDB.getAll(novelId);
  }

  Future<String?> getContent(int chapterNumber, String novelPath) async {
    final res = await ChapterDB.getContent(chapterNumber, novelPath);
    if (res == null) return null;
    return res.content;
  }

  Future<void> update(Chapter chapter) async {
    await ChapterDB.update(chapter);
  }

  Future<int> add(Chapter chapter) async {
    return await ChapterDB.add(chapter);
  }

  Future<void> deleteAllById(List<int> ids) async {
    await ChapterDB.deleteAllById(ids);
  }

  Future<void> delete(Chapter chapter) async {
    await ChapterDB.delete(chapter);
  }

  Future<void> deleteAll() async {
    await ChapterDB.deleteAll();
  }

  Future<void> deleteDBFile(String novelPath) async {
    await ChapterDB.deleteDBFile(novelPath);
  }
}
