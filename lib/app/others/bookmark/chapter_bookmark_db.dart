import 'package:novel_v3/app/core/interfaces/index.dart';

import 'chapter_bookmark_data.dart';

class ChapterBookmarkDB extends JsonDatabase<ChapterBookmarkData> {
  ChapterBookmarkDB._(String bookmarkPath) : super(root: bookmarkPath);

  static final Map<String, ChapterBookmarkDB> _instance = {};

  static ChapterBookmarkDB instance(String bookmarkPath) {
    return _instance.putIfAbsent(
      bookmarkPath,
      () => ChapterBookmarkDB._(bookmarkPath),
    );
  }

  static final Map<String, List<ChapterBookmarkData>> _caheList = {};

  void clearCacheList() {
    _caheList.clear();
  }

  Future<List<ChapterBookmarkData>> getCacheList({required String key}) async {
    if (_caheList.containsKey(key)) {
      _caheList[key] ?? [];
    } else {
      _caheList[key] = await getAll(query: {'isUsedCache': false});
    }
    return _caheList[key] ?? [];
  }

  Future<void> toggle({
    required int chapterNumber,
    required String key,
    String title = 'Untitled',
  }) async {
    final list = await getCacheList(key: key);
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
  ChapterBookmarkData from(Map<String, dynamic> map) {
    return ChapterBookmarkData.fromMap(map);
  }

  @override
  String getId(ChapterBookmarkData value) {
    return value.chapter.toString();
  }

  @override
  Map<String, dynamic> to(ChapterBookmarkData value) {
    return value.toMap();
  }
}
