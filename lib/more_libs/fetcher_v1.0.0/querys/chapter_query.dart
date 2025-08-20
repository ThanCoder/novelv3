// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/chapter_query_types.dart';

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
