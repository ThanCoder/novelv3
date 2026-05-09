import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/chapter_content.dart';
import 'package:t_db/t_db.dart';

class ChapterTDBAdapter extends TDAdapter<Chapter> {
  @override
  Chapter fromMap(Map<String, dynamic> map) {
    return Chapter.fromMap(map);
  }

  @override
  int getId(Chapter value) {
    return value.autoId;
  }

  @override
  int getUniqueFieldId() {
    return 1;
  }

  @override
  Map<String, dynamic> toMap(Chapter value) {
    return value.toMap();
  }
}

class ChapterContentTDBAdapter extends TDAdapter<ChapterContent> {
  @override
  ChapterContent fromMap(Map<String, dynamic> map) {
    return ChapterContent.fromMap(map);
  }

  @override
  int getId(ChapterContent value) {
    return value.autoId;
  }

  @override
  int getUniqueFieldId() {
    return 2;
  }

  @override
  Map<String, dynamic> toMap(ChapterContent value) {
    return value.toMap();
  }

  @override
  getFieldValue(ChapterContent value, String fieldName) {
    if (fieldName == 'chapterId') {
      return value.chapterId;
    }
  }
}
