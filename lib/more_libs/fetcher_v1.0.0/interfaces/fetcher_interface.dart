// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:novel_v3/more_libs/fetcher_v1.0.0/querys/f_query.dart';

import '../types/web_chapter.dart';

abstract class ChapterFetcherInterface {
  Future<String> title();
  Future<String> getContent();
}

abstract class DescriptionFetcherInterface {
  String title();
  String getAuthor();
  String getTranslator();
  String getDescription();
  String getTags();
  String? getCoverUrl();
}

abstract class WebChapterListFetcherInterface {
  FQuery titleQuery;
  FQuery urlQuery;
  FQuery contentQuery;
  WebChapterListFetcherInterface({
    required this.titleQuery,
    required this.urlQuery,
    required this.contentQuery,
  });
  List<WebChapter> getList(String html);
  String getContent(String html);
}

abstract class SupportedWebSiteInterface {
  final String title;
  final String url;
  final FQuery titleQuery;
  final FQuery? authorQuery;
  final FQuery? translatorQuery;
  final FQuery? descriptionQuery;
  final FQuery? tagsQuery;
  final FQuery? coverUrlQuery;
  final WebChapterListFetcherInterface? webChapterList;

  SupportedWebSiteInterface({
    required this.title,
    required this.url,
    required this.titleQuery,
    this.authorQuery,
    this.translatorQuery,
    this.descriptionQuery,
    this.tagsQuery,
    this.coverUrlQuery,
    this.webChapterList,
  });
}
