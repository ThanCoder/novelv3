import 'package:novel_v3/app/core/models/chapter.dart';

extension ChapterExtension on List<Chapter> {
  void sortChapterNumber({bool isSort = true}) {
    sort((a, b) {
      if (isSort) {
        if (a.number > b.number) return 1;
        if (a.number < b.number) return -1;
      } else {
        if (a.number > b.number) return -1;
        if (a.number < b.number) return 1;
      }
      return 0;
    });
  }
}
