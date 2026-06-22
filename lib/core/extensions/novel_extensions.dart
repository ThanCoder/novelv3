import 'package:novel_v3/core/models/novel.dart';

extension NovelExtensions on List<Novel> {
  void sortDate({bool isNewest = true}) {
    sort((a, b) {
      if (isNewest) {
        return b.meta.date.compareTo(a.meta.date);
      } else {
        return a.meta.date.compareTo(b.meta.date);
      }
    });
  }
}
