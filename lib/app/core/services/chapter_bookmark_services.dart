import 'dart:convert';
import 'dart:io';

import 'package:novel_v3/app/core/models/chapter_bookmark.dart';
import 'package:than_pkg/utils/f_path.dart';

class ChapterBookmarkServices {
  static const String dbOldName = 'fav_list2.json';
  static const String dbName = 'chapter-bookmark.json';

  static Future<List<ChapterBookmark>> getAll(String novelPath) async {
    List<ChapterBookmark> list = [];
    final contents = await _getDBContent(novelPath);
    if (contents.isEmpty) return list;
    List<dynamic> res = jsonDecode(contents);
    list = res.map((e) => ChapterBookmark.fromMap(e)).toList();
    return list;
  }

  static Future<void> setAll(
    List<ChapterBookmark> list,
    String novelPath,
  ) async {
    final dbFile = File(pathJoin(novelPath, dbName));
    final contents = list.map((e) => e.toMap()).toList();
    await dbFile.writeAsString(jsonEncode(contents));
  }

  static Future<String> _getDBContent(String novelPath) async {
    final dir = Directory(novelPath);
    if (!dir.existsSync()) return '';
    final dbFile = File(pathJoin(novelPath, dbName));
    final oldDBFile = File(pathJoin(novelPath, dbOldName));

    if (dbFile.existsSync()) {
      //new db
      return await dbFile.readAsString();
    } else if (oldDBFile.existsSync()) {
      // check old
      return await oldDBFile.readAsString();
    }
    return '';
  }
}
