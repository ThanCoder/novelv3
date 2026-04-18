import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
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

  static String _pathToKey(String path) {
    // final file = File(path);
    // return file.parent.getName();
    final digest = sha256.convert(utf8.encode(path));
    return digest.toString();
  }

  static void clearAll() {
    _dbMap.clear();
  }

  static void clear(String dbPath) {
    final key = _pathToKey(dbPath);
    _dbMap.remove(key);
  }

  static Future<TDB> _getCurrentDB(String dbPath) async {
    final key = _pathToKey(dbPath);
    if (_dbMap.containsKey(key)) return _dbMap[key]!;
    final db = TDB();
    db.setAdapter<Chapter>(ChapterAdapter());
    db.setAdapter<ChapterContent>(ChapterContentAdapter());
    await db.open(dbPath, config: _config);
    _dbMap[key] = db;
    // print(_dbMap);
    return db;
  }

  static Future<TDBox<Chapter>> getChapterBox(String novelId) async =>
      (await _getCurrentDB(getDBPath(novelId))).getBox<Chapter>();
  static Future<TDBox<ChapterContent>> getChapterContentBox(
    String novelId,
  ) async => (await _getCurrentDB(getDBPath(novelId))).getBox<ChapterContent>();

  static String getDBPath(String novelId) =>
      pathJoin(PathUtil.getSourcePath(name: novelId), 'chapters.db');

  static Future<List<Chapter>> getAll(String novelId) async {
    final chapterBox = await getChapterBox(novelId);
    final contentBox = await getChapterContentBox(novelId);

    final dbFile = File(novelId);

    if (dbFile.lengthSync() > 9) {
      return await chapterBox.getAll();
    } else {
      //chapter file တွေကို db ထဲထည့်မယ်
      final dir = Directory(novelId);
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
        final autoId = await chapterBox.add(chapter);
        // add content
        final content = await chapterFile.readAsString();
        await contentBox.add(
          ChapterContent(chapterId: autoId, content: content),
        );
        // delete added chapter file
        await chapterFile.delete();
      }
    }
    return await chapterBox.getAll();
  }

  static Future<ChapterContent?> getContent(
    int chapterNumber,
    String novelId,
  ) async {
    try {
      final chapterBox = await getChapterBox(novelId);
      final contentBox = await getChapterContentBox(novelId);

      final chapter = await chapterBox.getOne(
        (value) => value.number == chapterNumber,
      );
      if (chapter == null) return null;
      return await contentBox.getOne(
        (value) => value.chapterId == chapter.autoId,
      );
    } catch (e) {
      debugPrint('[ChapterDB:getContent]: $e');
      return null;
    }
  }

  ///
  /// return `newId`
  ///
  static Future<int> add(Chapter chapter, {required String novelId}) async {
    final chapterBox = await getChapterBox(novelId);
    final contentBox = await getChapterContentBox(novelId);

    //add new chapter
    final id = await chapterBox.add(chapter);
    if (chapter.content != null) {
      await contentBox.add(
        ChapterContent(chapterId: id, content: chapter.content ?? ''),
      );
    }
    final db = await _getCurrentDB(getDBPath(novelId));
    await db.flush();
    return id;
  }

  static Future<void> update(Chapter chapter, {required String novelId}) async {
    if (chapter.autoId == 0) throw Exception('`chapter.autoId` is 0');

    final chapterBox = await getChapterBox(novelId);
    final contentBox = await getChapterContentBox(novelId);

    // update chapter
    await chapterBox.updateById(chapter.autoId, chapter);

    final content = await contentBox.getOne(
      (value) => value.chapterId == chapter.autoId,
    );

    // check content
    if (content != null) {
      // delete
      await contentBox.deleteById(content.autoId);
    }
    await contentBox.add(
      ChapterContent(chapterId: chapter.autoId, content: chapter.content ?? ''),
    );

    final db = await _getCurrentDB(getDBPath(novelId));
    await db.flush();
  }

  static Future<void> delete(Chapter chapter, {required String novelId}) async {
    final box = await getChapterBox(novelId);
    await box.deleteById(chapter.autoId);

    final db = await _getCurrentDB(getDBPath(novelId));
    await db.flush();
  }

  static Future<void> deleteAll({required String novelId}) async {
    final box = await getChapterBox(novelId);

    await box.deleteAllRecord();
    await box.deleteAllRecord();

    final db = await _getCurrentDB(getDBPath(novelId));
    await db.flush();
  }

  static Future<void> deleteAllById(
    List<int> ids, {
    required String novelId,
  }) async {
    final box = await getChapterBox(novelId);
    await box.deleteAll(ids);
    final db = await _getCurrentDB(getDBPath(novelId));
    await db.flush();
  }

  static Future<void> deleteDBFile(String novelId) async {
    final file = File(getDBPath(novelId));
    if (file.existsSync()) {
      await file.delete();
    }
  }
}

//in background
Future<List<Chapter>> getAllChapterInBackground(String novelPath) async {
  final dbFile = File(pathJoin(novelPath, 'chapters.db'));
  final novelId = dbFile.getName();

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
    final dir = Directory(novelId);
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
