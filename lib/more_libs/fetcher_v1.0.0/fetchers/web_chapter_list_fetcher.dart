

import 'package:t_html_parser/t_html_parser.dart';

import '../interfaces/fetcher_interface.dart';
import '../types/web_chapter.dart';

class WebChapterListFetcher extends WebChapterListFetcherInterface {
  final String querySelectorAll;
  WebChapterListFetcher({
    required this.querySelectorAll,
    required super.titleQuery,
    required super.urlQuery,
    required super.contentQuery,
  });

  @override
  List<WebChapter> getList(String html) {
    List<WebChapter> list = [];
    final eles = html.toHtmlDocument.querySelectorAll(querySelectorAll);
    int index = (eles.length + 1);
    for (var ele in eles) {
      index--;
      final title = titleQuery.getResult(ele);
      final url = urlQuery.getResult(ele);
      list.add(WebChapter(title: title.trim(), url: url.trim(), index: index));
    }
    return list;
  }

  @override
  String getContent(String html) {
    final ele = html.toHtmlElement;
    if (ele == null) return '';
    return contentQuery.getResult(ele).trim();
  }
}
