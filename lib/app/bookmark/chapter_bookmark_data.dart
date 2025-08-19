import 'package:novel_v3/more_libs/json_database_v1.0.0/converter.dart';
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
  static ChapterBookmarkDataConverter get getConverter =>
      ChapterBookmarkDataConverter();
}

class ChapterBookmarkDataConverter
    implements MapConverter<ChapterBookmarkData> {
  @override
  ChapterBookmarkData from(Map<String, dynamic> map) {
    return ChapterBookmarkData.fromMap(map);
  }

  @override
  Map<String, dynamic> to(ChapterBookmarkData value) {
    return value.toMap();
  }
}
