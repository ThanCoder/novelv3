// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'fetcher.dart';

class FetchChapterQuery {
  String title;
  String content;
  FetcherTypes type;
  FetchChapterQuery({
    required this.title,
    required this.content,
    required this.type,
  });
}
