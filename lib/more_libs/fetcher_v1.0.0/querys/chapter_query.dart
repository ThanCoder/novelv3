import '../types/chapter_query_types.dart';

class ChapterQuery {
  String startHostUrl;
  String titleSelector;
  String contentSelector;
  ChapterQueryTypes type;
  ChapterQuery({
    required this.startHostUrl,
    required this.titleSelector,
    required this.contentSelector,
    required this.type,
  });
}
