import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/result_types.dart';
import 'package:t_client/t_client.dart';
import 'package:t_html_parser/core/q_result/attributes.dart';
import 'package:t_html_parser/core/q_result/query_result.dart';
import 'package:t_html_parser/core/t_html_extensions.dart';
import 'package:than_pkg/than_pkg.dart';

class FetchServices {
  static final FetchServices instance = FetchServices._();
  FetchServices._();
  factory FetchServices() => instance;
  final client = TClient();

  String getProxyUrl(String url) {
    final forward = getProxy();
    if (forward.isNotEmpty) {
      return '$forward${forward.contains('?') ? '&&' : '?'}url=$url';
    }
    return url;
  }

  String getProxy() {
    return TRecentDB.getInstance.getString('fetcher-proxy-url');
  }

  Future<void> setProxy(String proxyUrl) async {
    TRecentDB.getInstance.putString('fetcher-proxy-url', proxyUrl);
  }

  Future<NovelDetailResult?> fetchNovelDetail(
    String url, {
    required FetcherWebsite website,
  }) async {
    final res = await client.get(getProxyUrl(url));
    final html = res.data.toString();

    if (website.detailPageQuery != null) {
      final otherTitles = QueryResult(
        index: website.detailPageQuery!.otherTitles.index,
        attr: Attribute(website.detailPageQuery!.otherTitles.attribue),
        selector: website.detailPageQuery!.otherTitles.selector,
      );
      final author = QueryResult(
        index: website.detailPageQuery!.author.index,
        attr: Attribute(website.detailPageQuery!.author.attribue),
        selector: website.detailPageQuery!.author.selector,
      );
      final translator = QueryResult(
        index: website.detailPageQuery!.translator.index,
        attr: Attribute(website.detailPageQuery!.translator.attribue),
        selector: website.detailPageQuery!.translator.selector,
      );
      final description = QueryResult(
        index: website.detailPageQuery!.description.index,
        attr: Attribute(website.detailPageQuery!.description.attribue),
        selector: website.detailPageQuery!.description.selector,
      );
      return NovelDetailResult(
        otherTitles: otherTitles.getResult(html) ?? '',
        author: author.getResult(html) ?? '',
        translator: translator.getResult(html) ?? '',
        description: (description.getResult(html) ?? '').cleanHtmlTag(),
      );
    }
    return null;
  }

  Future<FetcherNovelResult> fetchNovelList(
    String url, {
    required FetcherWebsite website,
  }) async {
    final res = await client.get(getProxyUrl(url));
    final html = res.data.toString();

    List<NovelItemResult> list = [];

    final dom = html.toHtmlDocument;
    for (var ele in dom.querySelectorAll(
      website.novelListPageQuery.querySelectorAll,
    )) {
      // print(ele.innerHtml);
      // final title = ele.getQuerySelectorText(selector: '.luf a h3');
      final title = ele.getQuerySelectorText(
        selector: website.novelListPageQuery.titleQuery.selector,
      );
      final pageUrl = ele.getQuerySelectorAttr(
        selector: website.novelListPageQuery.pageUrlQuery.selector,
        attr: website.novelListPageQuery.pageUrlQuery.attribue,
      );
      final coverUrl = ele.getQuerySelectorAttr(
        selector: website.novelListPageQuery.coverUrlQuery.selector,
        attr: website.novelListPageQuery.coverUrlQuery.attribue,
      );
      list.add(
        NovelItemResult(title: title, pageUrl: pageUrl, coverUrl: coverUrl),
      );
    }
    final nextUrlEles = dom.querySelectorAll(
      website.novelListPageQuery.nextUrlQuery.selector,
    );
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

  Future<ChapterContentResult> fetchChapter(
    String url, {
    required FetcherWebsite website,
  }) async {
    final res = await client.get(getProxyUrl(url));
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
        afterQuery: (attr, result) {
          return result?.cleanHtmlTag();
        },
      ).getResult(html);
    }
    return ChapterContentResult(title: title ?? '', content: content ?? '');
  }

  Future<List<MultiChapterResult>> fetchMultiChapter(
    String url, {
    required FetcherWebsite website,
    bool startChapterNumberSmallToBig = true,
  }) async {
    final res = await client.get(getProxyUrl(url));
    final html = res.data.toString();
    final dom = html.toHtmlDocument;
    List<MultiChapterResult> list = [];
    int chNumber = 1;
    final eles = dom.querySelectorAll('.ts-chl-collapsible-content ul li');
    if (!startChapterNumberSmallToBig) {
      chNumber = eles.length;
    }
    for (var ele in eles) {
      final url = ele.getQuerySelectorAttr(selector: 'a', attr: 'href');
      final title = ele.getQuerySelectorText(selector: '.epl-title');
      // print('CH: $chNumber - title: $title - url: $url');
      list.add(MultiChapterResult(chNumber: chNumber, title: title, url: url));
      // auto chapter number
      if (startChapterNumberSmallToBig) {
        chNumber++;
      } else {
        chNumber--;
      }
    }
    return list;
  }

  List<FetcherWebsite> fetcherWebsiteList() {
    return [
      FetcherWebsite(
        url: 'https://mmxianxia.com',
        title: 'MM Xianxia',
        novelListPageQuery: NovelListPageQuery(
          querySelectorAll: '.styletree',
          titleQuery: FetcherQuery(
            index: 0,
            attribue: HtmlAttribute.text.name,
            selector: '.luf a h3',
          ),
          pageUrlQuery: FetcherQuery(
            index: 0,
            attribue: HtmlAttribute.href.name,
            selector: '.luf a',
          ),
          coverUrlQuery: FetcherQuery(
            index: 0,
            attribue: 'data-src',
            selector: '.ts-post-image',
          ),
          nextUrlQuery: FetcherQuery(
            index: 0,
            attribue: HtmlAttribute.href.name,
            selector: '.hpage a',
          ),
        ),
        chapterPageQuery: ChapterPageQuery(
          titleQuery: FetcherQuery(
            index: 0,
            attribue: HtmlAttribute.text.name,
            selector: '.entry-title',
          ),
          contentQuery: FetcherQuery(
            index: 0,
            attribue: HtmlAttribute.html.name,
            selector: '.entry-content',
          ),
        ),
        detailPageQuery: DetailPageQuery(
          otherTitles: FetcherQuery(
            index: 0,
            attribue: HtmlAttribute.text.value,
            selector: '.sertoinfo .alter',
          ),
          author: FetcherQuery(
            index: 1,
            attribue: HtmlAttribute.text.value,
            selector: '.sertoauth .serval',
          ),
          translator: FetcherQuery(
            index: 1,
            attribue: HtmlAttribute.text.value,
            selector: '.sertoauth .serval',
          ),
          description: FetcherQuery(
            index: 0,
            attribue: HtmlAttribute.html.value,
            selector: '.entry-content',
          ),
        ),
      ),
      FetcherWebsite(
        url: 'https://novelhi.com',
        title: 'Novel HI',
        novelListPageQuery: NovelListPageQuery.createEmpty(),
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
