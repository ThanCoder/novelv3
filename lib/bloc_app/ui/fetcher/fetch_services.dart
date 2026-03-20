import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/result_types.dart';
import 'package:t_client/t_client.dart';
import 'package:t_html_parser/core/q_result/attributes.dart';
import 'package:t_html_parser/core/q_result/query_result.dart';
import 'package:t_html_parser/core/t_html_extensions.dart';

class FetchServices {
  static final FetchServices instance = FetchServices._();
  FetchServices._();
  factory FetchServices() => instance;
  final client = TClient();

  Future<FetcherNovelResult> fetchNovelList(
    String url, {
    required FetcherWebsite website,
  }) async {
    final res = await client.get(url);
    final html = res.data.toString();

    List<NovelItemResult> list = [];

    final dom = html.toHtmlDocument;
    for (var ele in dom.querySelectorAll('.styletree')) {
      // print(ele.innerHtml);
      final title = ele.getQuerySelectorText(selector: '.luf a h3');
      final pageUrl = ele.getQuerySelectorAttr(
        selector: '.luf a',
        attr: 'href',
      );
      final coverUrl = ele.getQuerySelectorAttr(
        selector: '.ts-post-image',
        attr: 'data-src',
      );
      list.add(
        NovelItemResult(title: title, pageUrl: pageUrl, coverUrl: coverUrl),
      );
    }
    final nextUrlEles = dom.querySelectorAll('.hpage a');
    String nextUrl = '';
    if (nextUrlEles.isNotEmpty) {
      nextUrl = nextUrlEles.last.attributes['href'] ?? '';
    }

    // final nextUrl = QueryResult(
    //   index: 0,
    //   attr: Attribute('href'),
    //   selector: '.hpage a',
    // ).getResult(html);
    return FetcherNovelResult(list: list, nextUrl: nextUrl);
  }

  Future<FetcherWebsiteResult> fetchChapter(
    String url, {
    required FetcherWebsite website,
  }) async {
    final res = await client.get(url);
    final html = res.data.toString();
    String? title, content;

    if (website.chapterPageQuery != null) {
      title = QueryResult(
        index: website.chapterPageQuery!.titleQuery.index,
        attr: Attribute(website.chapterPageQuery!.titleQuery.attribue),
        selector: website.chapterPageQuery!.titleQuery.selector,
      ).getResult(html);
      content = QueryResult(
        index: website.chapterPageQuery!.contentQuery.index,
        attr: Attribute(website.chapterPageQuery!.contentQuery.attribue),
        selector: website.chapterPageQuery!.contentQuery.selector,
      ).getResult(html);
    }
    return FetcherWebsiteResult(title: title ?? '', content: content ?? '');
  }

  List<FetcherWebsite> fetcherWebsiteList() {
    return [
      FetcherWebsite(
        url: 'https://mmxianxia.com',
        title: 'MM Xianxia',
        chapterPageQuery: ChapterPageQuery(
          titleQuery: FetcherQuery(
            index: 0,
            attribue: HtmlAttribute.text.name,
            selector: '.entry-title',
          ),
          contentQuery: FetcherQuery(
            index: 0,
            attribue: HtmlAttribute.text.name,
            selector: '.entry-content',
          ),
        ),
      ),
      FetcherWebsite(
        url: 'https://novelhi.com',
        title: 'Novel HI',
        chapterPageQuery: ChapterPageQuery(
          titleQuery: FetcherQuery(
            index: 0,
            attribue: HtmlAttribute.text.name,
            selector: '.book_title h1',
          ),
          contentQuery: FetcherQuery(
            index: 0,
            attribue: HtmlAttribute.text.name,
            selector: '.readBox',
          ),
        ),
      ),
    ];
  }
}
