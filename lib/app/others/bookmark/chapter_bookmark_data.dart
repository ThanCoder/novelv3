import 'package:than_pkg/services/map_services.dart';

class ChapterBookmarkData {
  String title;
  int chapter;
  ChapterBookmarkData({required this.title, required this.chapter});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'title': title, 'chapter': chapter};
  }

  factory ChapterBookmarkData.fromMap(Map<String, dynamic> map) {
    return ChapterBookmarkData(
      title: MapServices.getString(map, ['title'], defaultValue: 'Untitled'),
      chapter: MapServices.getInt(map, ['chapter']),
    );
  }
}

extension ChapterBookmarkDataExtension on List<ChapterBookmarkData> {
  void sortChapter({bool isAsc = true}) {
    sort((a, b) {
      if (isAsc) {
        if (a.chapter > b.chapter) return 1;
        if (a.chapter < b.chapter) return -1;
      } else {
        if (a.chapter > b.chapter) return -1;
        if (a.chapter < b.chapter) return 1;
      }
      return 0;
    });
  }
}
