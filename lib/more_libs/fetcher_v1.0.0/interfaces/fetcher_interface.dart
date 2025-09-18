import '../querys/f_query.dart';
import '../types/web_chapter.dart';
import '../types/website_info.dart';

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
  final WebsiteInfo info;
  final WebChapterListFetcherInterface? webChapterList;

  SupportedWebSiteInterface({
    required this.title,
    required this.url,
    required this.info,
    this.webChapterList,
  });
}

