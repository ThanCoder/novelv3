import 'package:novel_v3/app/core/databases/chapter_db.dart';
import 'package:novel_v3/app/core/models/chapter.dart';

class ChapterServices {
  static Future<List<Chapter>> getAll(String novelPath) async {
    return await ChapterDB.getAll(novelPath);
  }

  static Future<String?> getContent(int chapterNumber, String novelPath) async {
    final content = await ChapterDB.getContent(chapterNumber, novelPath);
    if (content == null) return null;
    return content.content;
  }

  static Future<void> update(Chapter chapter) async {
    await ChapterDB.update(chapter);
  }

  static Future<int> add(Chapter chapter) async {
    return await ChapterDB.add(chapter);
  }

  static Future<void> delete(Chapter chapter) async {
    await ChapterDB.delete(chapter);
  }

  static Future<void> deleteAll() async {
    await ChapterDB.deleteAll();
  }

  static Future<void> deleteDBFile(String novelPath) async {
    await ChapterDB.deleteDBFile(novelPath);
  }
}
