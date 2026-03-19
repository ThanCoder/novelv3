import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';
import 'package:t_client/t_client.dart';
import 'package:t_html_parser/core/q_result/attributes.dart';
import 'package:t_html_parser/core/q_result/query_result.dart';

class FetcherWebsiteResult {
  final String title;
  final String content;

  const FetcherWebsiteResult({required this.title, required this.content});
}

class FetchServices {
  static final FetchServices instance = FetchServices._();
  FetchServices._();
  factory FetchServices() => instance;
  final client = TClient();

  Future<FetcherWebsiteResult> fetchHtml(
    String url, {
    required FetcherWebsite website,
  }) async {
    final res = await client.get(url);
    final html = res.data.toString();
    final title = QueryResult(
      index: website.titleQuery.index,
      attr: Attribute(website.titleQuery.attribue),
      selector: website.titleQuery.selector,
    );
    final content = QueryResult(
      index: website.contentQuery.index,
      attr: Attribute(website.contentQuery.attribue),
      selector: website.contentQuery.selector,
    );
    // print(title.getResult(html));
    // print(content.getResult(html));
    return FetcherWebsiteResult(
      title: title.getResult(html) ?? '',
      content: content.getResult(html) ?? '',
    );
  }

  List<FetcherWebsite> fetcherWebsiteList() {
    return [
      FetcherWebsite(
        url: 'https://mmxianxia.com',
        title: 'MM Xianxia',
        titleQuery: FetcherWebsiteQuery(
          index: 0,
          attribue: HtmlAttribute.text.name,
          selector: '.entry-title',
        ),
        contentQuery: FetcherWebsiteQuery(
          index: 0,
          attribue: HtmlAttribute.text.name,
          selector: '.entry-content',
        ),
      ),
    ];
  }
}
