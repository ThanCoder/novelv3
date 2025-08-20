import 'package:novel_v3/more_libs/json_database_v1.0.0/json_database.dart';
import 'chapter_bookmark_data.dart';

class ChapterBookmarkDB extends JsonDBInterface<ChapterBookmarkData> {
  ChapterBookmarkDB._(String bookmarkPath)
    : super(JsonIO.instance, bookmarkPath);

  static final Map<String, ChapterBookmarkDB> _instance = {};

  static ChapterBookmarkDB instance(String bookmarkPath) {
    return _instance.putIfAbsent(
      bookmarkPath,
      () => ChapterBookmarkDB._(bookmarkPath),
    );
  }

  static List<ChapterBookmarkData> _caheList = [];

  void clearCacheList() {
    _caheList.clear();
  }

  Future<List<ChapterBookmarkData>> getCacheList() async {
    if (_caheList.isEmpty) {
      _caheList = await get();
    }
    return _caheList;
  }

  Future<void> toggle(int chapterNumber, {String title = 'Untitled'}) async {
    final list = await getCacheList();
    final index = list.indexWhere((e) => e.chapter == chapterNumber);
    final isExists = index != -1;
    if (isExists) {
      list.removeAt(index);
    } else {
      list.add(ChapterBookmarkData(title: title, chapter: chapterNumber));
    }
    await save(list);
  }

  @override
  ChapterBookmarkData fromMap(Map<String, dynamic> map) {
    return ChapterBookmarkData.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(ChapterBookmarkData value) {
    return value.toMap();
  }
}
