import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/models/chapter_content.dart';
import 'package:t_db/t_db.dart';
import 'package:than_pkg/than_pkg.dart';

class ChapterDB {
  static final db = TDB.getInstance();
  static final _config = DBConfig.getDefault().copyWith(
    saveLocalDBLock: false,
    saveBackupDBCompact: false,
  );

  static void setAdapters() {
    db.setAdapter<Chapter>(ChapterAdapter());
    db.setAdapter<ChapterContent>(ChapterContentAdapter());
  }

  static Future<void> _open(String path) async {
    try {
      await db.open(path, config: _config);
    } catch (e) {
      debugPrint('[ChapterDB:_open]: ${e.toString()}');
    }
  }

  static Future<List<Chapter>> getAll(String novelPath) async {
    final dbFile = File(getDBPath(novelPath));
    await _open(dbFile.path);

    if (dbFile.lengthSync() > 9) {
      return await getChapterBox.getAll();
    } else {
      //chapter file တွေကို db ထဲထည့်မယ်
      final dir = Directory(novelPath);
      for (var file in dir.listSync(followLinks: false)) {
        if (!file.isFile) continue;

        final title = file.getName();
        if (!Chapter.isChapterFile(title)) continue;
        final chapter = Chapter(
          number: int.parse(title),
          title: 'Untitled',
          date: file.getDate,
          novelPath: novelPath,
        );
        final chapterFile = File(file.path);
        final autoId = await getChapterBox.add(chapter);
        // add content
        final content = await chapterFile.readAsString();
        await getChapterContentBox.add(
          ChapterContent(chapterId: autoId, content: content),
        );
        // delete added chapter file
        await chapterFile.delete();
      }
    }
    return await getChapterBox.getAll();
  }

  static Future<ChapterContent?> getContent(
    int chapterNumber,
    String novelPath,
  ) async {
    final chapter = await getChapterBox.getOne(
      (value) => value.number == chapterNumber,
    );
    if (chapter == null) return null;
    return await getChapterContentBox.getOne(
      (value) => value.chapterId == chapter.autoId,
    );
  }

  ///
  /// return `newId`
  ///
  static Future<int> add(Chapter chapter) async {
    //add new chapter
    final id = await getChapterBox.add(chapter);
    if (chapter.content != null) {
      await getChapterContentBox.add(
        ChapterContent(chapterId: id, content: chapter.content ?? ''),
      );
    }
    return id;
  }

  static Future<void> update(Chapter chapter) async {
    if (chapter.autoId == 0) throw Exception('`chapter.autoId` is 0');

    // update chapter
    await getChapterBox.updateById(chapter.autoId, chapter);

    final content = await getChapterContentBox.getOne(
      (value) => value.chapterId == chapter.autoId,
    );

    // check content
    if (content != null) {
      // delete
      await getChapterContentBox.deleteById(content.autoId);
    }
    await getChapterContentBox.add(
      ChapterContent(chapterId: chapter.autoId, content: chapter.content ?? ''),
    );
  }

  static Future<void> delete(Chapter chapter) async {
    await getChapterBox.deleteById(chapter.autoId);
  }

  static Future<void> deleteAll() async {
    await getChapterBox.deleteAllRecord();
    await getChapterContentBox.deleteAllRecord();
  }

  static Future<void> deleteAllById(List<int> ids) async {
    await getChapterBox.deleteAll(ids);
  }

  static Future<void> deleteDBFile(String novelPath) async {
    final file = File(getDBPath(novelPath));
    if (file.existsSync()) {
      await file.delete();
    }
  }

  static TDBox<Chapter> get getChapterBox => db.getBox<Chapter>();
  static TDBox<ChapterContent> get getChapterContentBox =>
      db.getBox<ChapterContent>();

  static String getDBPath(String novelPath) =>
      pathJoin(novelPath, 'chapters.db');
}
