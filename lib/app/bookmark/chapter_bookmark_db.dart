import 'package:novel_v3/more_libs/json_database_v1.0.0/json_database.dart';
import 'chapter_bookmark_data.dart';

class ChapterBookmarkDB extends DBStrategy<ChapterBookmarkData> {
  ChapterBookmarkDB._(String path)
    : super(JsonIO(), path, ChapterBookmarkData.getConverter);

  static final Map<String, ChapterBookmarkDB> _instance = {};

  static ChapterBookmarkDB instance(String path) {
    return _instance.putIfAbsent(path, () => ChapterBookmarkDB._(path));
  }
}
