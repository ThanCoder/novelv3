import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/chapter_bookmark.dart';

extension ChapterExtension on List<Chapter> {
  void sortChapterNumber({bool isSort = true}) {
    sort((a, b) {
      if (isSort) {
        return a.number.compareTo(b.number);
      } else {
        return b.number.compareTo(a.number);
      }
    });
  }
}

extension ChapterBookmarkExtension on List<ChapterBookmark> {
  void sortChapterNumber({bool isSort = true}) {
    sort((a, b) {
      if (isSort) {
        return a.chapter.compareTo(b.chapter);
      } else {
        return b.chapter.compareTo(a.chapter);
      }
    });
  }
}
