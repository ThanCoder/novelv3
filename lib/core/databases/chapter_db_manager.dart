import 'package:chapters_db/chapters_db.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';

class ChapterDBManager {
  static final oldChapterDBName = 'chapters.db';
  static final newChapterDBName = 'chapters.2.db';
  static final Map<String, ChaptersDB> _dbCache = {};
  // static final db = ChaptersDB.getInstance();
  // static final box = db.getDefaultBox();

  static String getDBPath(String novelId) =>
      PathUtil.getSourcePath(name: novelId).pathJoin(newChapterDBName);

  static Future<ChBox<DefaultChapter>> getBox(String novelId) async {
    final db = await getDB(novelId);
    return db.getDefaultBox();
  }

  static Future<ChaptersDB> getDB(String novelId) async {
    if (_dbCache.containsKey(novelId)) {
      return _dbCache[novelId]!;
    }
    final db = ChaptersDB();
    await db.open(getDBPath(novelId));
    _dbCache[novelId] = db;
    return db;
  }

  static void removeDB(String novelId) {
    if (_dbCache.containsKey(novelId)) {
      _dbCache[novelId]!.close();
      _dbCache.remove(novelId);
    }
  }

  static Future<List<ChapterInfo<DefaultChapter>>> getAll(
    String novelId,
  ) async {
    final db = ChaptersDB();
    if (db.isOpened) {
      await db.close();
    }
    await db.open(
      PathUtil.getSourcePath(name: novelId).pathJoin(newChapterDBName),
    );
    final box = db.getDefaultBox();
    return await box.getAll();
  }

  static Future<DefaultChapter> getContent(
    ChapterInfo<DefaultChapter> info,
  ) async {
    return await info.getContent();
  }
}
