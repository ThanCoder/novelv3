import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/chapter_content.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:t_db/t_db.dart';
import 'package:than_pkg/than_pkg.dart';

class ChapterDB {
  static final Map<String, TDB> _dbMap = {};
  static final _config = DBConfig.getDefault().copyWith(
    saveLocalDBLock: false,
    saveBackupDBCompact: false,
  );
  static Future<void> _openAlreadyDB(String path) async {
    if (!_dbMap.containsKey(path)) {
      await _getCurrentDB(path).open(path, config: _config);
    }
  }

  static TDB _getCurrentDB(String path) {
    if (_dbMap[path] != null) return _dbMap[path]!;
    final db = TDB();
    db.setAdapter<Chapter>(ChapterAdapter());
    db.setAdapter<ChapterContent>(ChapterContentAdapter());
    _dbMap[path] = db;
    return db;
  }

  static Future<List<Chapter>> getAll(String novelId) async {
    final novelPath = getDBPath(PathUtil.getSourcePath(name: novelId));
    // open db
    await _openAlreadyDB(novelPath);

    final dbFile = File(novelPath);

    if (dbFile.lengthSync() > 9) {
      return await getChapterBox(novelPath).getAll();
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
          novelId: novelId,
        );
        final chapterFile = File(file.path);
        final autoId = await getChapterBox(novelPath).add(chapter);
        // add content
        final content = await chapterFile.readAsString();
        await getChapterContentBox(
          novelPath,
        ).add(ChapterContent(chapterId: autoId, content: content));
        // delete added chapter file
        await chapterFile.delete();
      }
    }
    return await getChapterBox(novelPath).getAll();
  }

  static Future<ChapterContent?> getContent(
    int chapterNumber,
    String novelId,
  ) async {
    try {
      final novelPath = getDBPath(PathUtil.getSourcePath(name: novelId));
      // open db
      await _openAlreadyDB(novelPath);

      final chapter = await getChapterBox(
        novelPath,
      ).getOne((value) => value.number == chapterNumber);
      if (chapter == null) return null;
      return await getChapterContentBox(
        novelPath,
      ).getOne((value) => value.chapterId == chapter.autoId);
    } catch (e) {
      debugPrint('[ChapterDB:getContent]: $e');
      return null;
    }
  }

  ///
  /// return `newId`
  ///
  static Future<int> add(Chapter chapter, {required String novelId}) async {
    final novelPath = getDBPath(PathUtil.getSourcePath(name: novelId));
    // open db
    await _openAlreadyDB(novelPath);

    //add new chapter
    final id = await getChapterBox(novelPath).add(chapter);
    if (chapter.content != null) {
      await getChapterContentBox(
        novelPath,
      ).add(ChapterContent(chapterId: id, content: chapter.content ?? ''));
    }
    return id;
  }

  static Future<void> update(Chapter chapter, {required String novelId}) async {
    final novelPath = getDBPath(PathUtil.getSourcePath(name: novelId));
    // open db
    await _openAlreadyDB(novelPath);
    if (chapter.autoId == 0) throw Exception('`chapter.autoId` is 0');

    // update chapter
    await getChapterBox(novelPath).updateById(chapter.autoId, chapter);

    final content = await getChapterContentBox(
      novelPath,
    ).getOne((value) => value.chapterId == chapter.autoId);

    // check content
    if (content != null) {
      // delete
      await getChapterContentBox(novelPath).deleteById(content.autoId);
    }
    await getChapterContentBox(novelPath).add(
      ChapterContent(chapterId: chapter.autoId, content: chapter.content ?? ''),
    );
  }

  static Future<void> delete(Chapter chapter, {required String novelId}) async {
    final novelPath = getDBPath(PathUtil.getSourcePath(name: novelId));
    // open db
    await _openAlreadyDB(novelPath);
    await getChapterBox(novelPath).deleteById(chapter.autoId);
  }

  static Future<void> deleteAll({required String novelId}) async {
    final novelPath = getDBPath(PathUtil.getSourcePath(name: novelId));
    // open db
    await _openAlreadyDB(novelPath);

    await getChapterBox(novelPath).deleteAllRecord();
    await getChapterContentBox(novelPath).deleteAllRecord();
  }

  static Future<void> deleteAllById(
    List<int> ids, {
    required String novelId,
  }) async {
    final novelPath = getDBPath(PathUtil.getSourcePath(name: novelId));
    // open db
    await _openAlreadyDB(novelPath);

    await getChapterBox(novelPath).deleteAll(ids);
  }

  static Future<void> deleteDBFile(String novelId) async {
    final novelPath = getDBPath(PathUtil.getSourcePath(name: novelId));
    // open db
    await _openAlreadyDB(novelPath);

    final file = File(getDBPath(novelPath));
    if (file.existsSync()) {
      await file.delete();
    }
  }

  static TDBox<Chapter> getChapterBox(String path) =>
      _getCurrentDB(path).getBox<Chapter>();
  static TDBox<ChapterContent> getChapterContentBox(String path) =>
      _getCurrentDB(path).getBox<ChapterContent>();

  static String getDBPath(String novelPath) =>
      pathJoin(novelPath, 'chapters.db');
}

Future<List<Chapter>> getAllChapterInBackground(String novelPath) async {
  final dbFile = File(pathJoin(novelPath, 'chapters.db'));
  final novelId = novelPath.getName();

  final db = TDB();
  await db.open(
    dbFile.path,
    config: DBConfig.getDefault().copyWith(
      saveLocalDBLock: false,
      saveBackupDBCompact: false,
    ),
  );
  db.setAdapter<Chapter>(ChapterAdapter());
  db.setAdapter<ChapterContent>(ChapterContentAdapter());

  TDBox<Chapter> getChapterBox = db.getBox<Chapter>();
  TDBox<ChapterContent> getChapterContentBox = db.getBox<ChapterContent>();

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
        novelId: novelId,
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
  await db.close();
  return await getChapterBox.getAll();
}
