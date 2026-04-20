import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/result_types.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/types/fetch_website.dart';
import 'package:novel_v3/bloc_app/ui/webview/fetch_webview_screen.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:novel_v3/core/utils.dart';
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
    BuildContext context,
    String url, {
    required FetcherWebsite website,
  }) async {
    final html = await _fetchView(context, url, website.type);

    if (website.detailPageQuery != null) {
      return NovelDetailResult(
        title: website.detailPageQuery!.title.getResult(html).join(','),
        coverUrl: website.detailPageQuery!.coverUrl.getResult(html).join(''),
        author: website.detailPageQuery!.author.getResult(html).join(''),
        otherTitles:
            website.detailPageQuery!.otherTitles?.getResult(html) ?? [],
        translator:
            website.detailPageQuery!.translator?.getResult(html).join('') ?? '',
        description: website.detailPageQuery!.description
            .getResult(html)
            .join('')
            .cleanHtmlTag(),
        tags: website.detailPageQuery!.tags.getResult(html),
      );
    }
    return null;
  }

  /// Fetch Fetch Type
  Future<String> _fetchView(
    BuildContext context,
    String url,
    FetchType type,
  ) async {
    final completer = Completer<String>();
    if (type == FetchType.webview) {
      context.goRoute(
        builder: (context) => FetchWebviewScreen(
          url: url,
          onResult: (resultHtml) => completer.complete(resultHtml),
          onClosed: () {
            if (!completer.isCompleted) {
              completer.complete('');
            }
          },
        ),
      );
    } else {
      final res = await client.get(getProxyUrl(url));
      completer.complete(res.data.toString());
    }
    return completer.future;
  }

  Future<FetcherNovelResult> fetchNovelList(
    BuildContext context,
    String url, {
    required FetcherWebsite website,
  }) async {
    List<NovelItemResult> list = [];
    final html = await _fetchView(context, url, website.type);

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
        NovelItemResult(
          title: title,
          pageUrl: pageUrl.formatUrl(website.hostUrl),
          coverUrl: coverUrl.formatUrl(website.hostUrl),
        ),
      );
    }
    // fetch next urls
    final nextUrls = <FetcherNovelNextUrl>[];
    if (website.novelListPageQuery.nextUrlQuery != null) {
      if (website
          .novelListPageQuery
          .nextUrlQuery!
          .querySelectorAll
          .isNotEmpty) {
        for (var ele in dom.querySelectorAll(
          website.novelListPageQuery.nextUrlQuery!.querySelectorAll,
        )) {
          final title = website.novelListPageQuery.nextUrlQuery!.itemTextQuery
              .getFromElement(ele);
          final nextUrl = website.novelListPageQuery.nextUrlQuery!.itemUrlQuery
              .getFromElement(ele);
          // print(url.formatUrl(website.hostUrl));

          nextUrls.add(
            FetcherNovelNextUrl(
              title: title,
              url: nextUrl.formatUrl(
                website.novelListPageQuery.nextUrlQuery!.hostUrl ??
                    website.hostUrl,
              ),
            ),
          );
        }
      }
    }

    return FetcherNovelResult(list: list, nextUrls: nextUrls);
  }

  Future<ChapterContentResult> fetchChapter(
    BuildContext context,
    String url, {
    required FetcherWebsite website,
  }) async {
    final html = await _fetchView(context, url, website.type);
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
    BuildContext context,
    String url, {
    required FetcherWebsite website,
    bool startChapterNumberSmallToBig = true,
  }) async {
    final html = await _fetchView(context, url, website.type);

    final dom = html.toHtmlDocument;

    List<MultiChapterResult> list = [];
    if (website.chapterListPageQuery != null) {
      int chNumber = 1;

      final eles = dom.querySelectorAll(
        website.chapterListPageQuery!.querySelectorAll,
      );
      if (!startChapterNumberSmallToBig) {
        chNumber = eles.length;
      }
      for (var ele in eles) {
        // final url = ele.getQuerySelectorAttr(selector: 'a', attr: 'href');
        // final title = ele.getQuerySelectorText(selector: '.epl-title');
        final url = website.chapterListPageQuery!.pageUrlQuery.getFromElement(
          ele,
        );
        final title = website.chapterListPageQuery!.titleQuery.getFromElement(
          ele,
        );
        // print('CH: $chNumber - title: $title - url: $url');
        list.add(
          MultiChapterResult(chNumber: chNumber, title: title, url: url),
        );
        // auto chapter number
        if (startChapterNumberSmallToBig) {
          chNumber++;
        } else {
          chNumber--;
        }
      }
    }

    return list;
  }

  static List<FetcherWebsite> _websiteListCache = [];

  Future<List<FetcherWebsite>> getWebsiteList({bool isLocal = false}) async {
    if (_websiteListCache.isNotEmpty) {
      return _websiteListCache;
    }
    if (isLocal) {
      final file = File('fetch-websites-list.json');
      if (file.existsSync()) {
        List<dynamic> jsonList = jsonDecode(await file.readAsString());
        _websiteListCache = jsonList
            .map((e) => FetcherWebsite.fromJson(e))
            .toList();
        return _websiteListCache;
      }
    } else {
      //onlie
      final url =
          'https://raw.githubusercontent.com/ThanCoder/novelv3/refs/heads/main/fetch-websites-list.json';
      final res = await client.get(url);
      if (res.statusCode == 200) {
        try {
          List<dynamic> jsonList = jsonDecode(res.data.toString());
          _websiteListCache = jsonList
              .map((e) => FetcherWebsite.fromJson(e))
              .toList();
          return _websiteListCache;
        } catch (e) {
          debugPrint('[getWebsiteList:online->api]: $e');
        }
      }
    }
    _websiteListCache = [
      FetcherWebsite(
        hostUrl: 'https://mmxianxia.com',
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
          nextUrlQuery: NextUrlQuery(
            querySelectorAll: '.hpage a',
            itemTextQuery: FetcherQuery(
              attribue: HtmlAttribute.text.name,
              selector: '',
            ),
            itemUrlQuery: FetcherQuery(
              attribue: HtmlAttribute.href.name,
              selector: '',
            ),
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
          title: FetcherQuery(
            attribue: HtmlAttribute.text.value,
            selector: '.entry-title,.cat-series',
            type: FetcherQueryType.list,
          ),
          coverUrl: FetcherQuery(
            index: 0,
            attribue: 'data-src',
            selector: '.wp-post-image',
          ),
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
            index: 2,
            attribue: HtmlAttribute.text.value,
            selector: '.sertoauth .serval',
          ),
          description: FetcherQuery(
            index: 0,
            attribue: HtmlAttribute.html.value,
            selector: '.entry-content',
          ),
          tags: FetcherQuery(
            attribue: HtmlAttribute.text.value,
            selector: '.sertogenre a',
            type: FetcherQueryType.list,
          ),
        ),
        chapterListPageQuery: ChapterListPageQuery(
          querySelectorAll: '.ts-chl-collapsible-content ul li',
          pageUrlQuery: FetcherQuery(attribue: 'href', selector: 'a'),
          titleQuery: FetcherQuery(attribue: 'text', selector: '.epl-title'),
          numberQuery: FetcherQuery(attribue: '', selector: ''),
        ),
      ),
      FetcherWebsite(
        type: FetchType.webview,
        hostUrl: 'https://lightnovelworld.org',
        url: 'https://lightnovelworld.org/genre-all/?order=new',
        title: 'Light Novel World',
        novelListPageQuery: NovelListPageQuery(
          querySelectorAll: '.results-section .recommendation-card',
          titleQuery: FetcherQuery(attribue: 'text', selector: '.card-title'),
          pageUrlQuery: FetcherQuery(
            attribue: 'href',
            selector: '.card-cover-link',
          ),
          coverUrlQuery: FetcherQuery(
            attribue: 'src',
            selector: '.card-cover img',
          ),
          nextUrlQuery: NextUrlQuery(
            querySelectorAll: '.pagination a',
            hostUrl: 'https://lightnovelworld.org/genre-all',
            itemTextQuery: FetcherQuery(attribue: 'text', selector: ''),
            itemUrlQuery: FetcherQuery(attribue: 'href', selector: ''),
          ),
        ),
        detailPageQuery: DetailPageQuery(
          title: FetcherQuery(
            attribue: HtmlAttribute.text.value,
            selector: '.novel-title',
          ),
          author: FetcherQuery(
            attribue: HtmlAttribute.text.value,
            selector: '.novel-author a',
          ),
          coverUrl: FetcherQuery(
            attribue: HtmlAttribute.src.value,
            selector: '.novel-cover',
          ),
          otherTitles: null,
          translator: null,
          description: FetcherQuery(
            attribue: HtmlAttribute.html.value,
            selector: '.summary-section',
          ),
          tags: FetcherQuery(
            attribue: HtmlAttribute.text.value,
            selector: '.genre-tags',
            type: FetcherQueryType.list,
          ),
        ),
        chapterListPageQuery: ChapterListPageQuery(
          querySelectorAll: '.chapters-grid .chapter-card',
          pageUrlQuery: FetcherQuery(attribue: 'onclick', selector: ''),
          titleQuery: FetcherQuery(
            attribue: HtmlAttribute.text.value,
            selector: '.chapter-title',
          ),
          numberQuery: FetcherQuery(
            attribue: HtmlAttribute.text.value,
            selector: '.chapter-number',
          ),
          nextUrlQuery: NextUrlQuery(
            querySelectorAll: '.pagination-pages .page-link',
            itemUrlQuery: FetcherQuery(
              attribue: HtmlAttribute.href.value,
              selector: '',
            ),
            itemTextQuery: FetcherQuery(attribue: 'title', selector: ''),
          ),
        ),
        chapterPageQuery: ChapterPageQuery(
          titleQuery: FetcherQuery(
            attribue: 'text',
            selector: '.chapter-title',
          ),
          contentQuery: FetcherQuery(
            attribue: 'html',
            selector: '.chapter-content',
          ),
        ),
      ),
      FetcherWebsite(
        type: FetchType.webview,
        hostUrl: 'https://novelhi.com',
        url: 'https://novelhi.com/novel',
        title: 'Novel HI',
        novelListPageQuery: NovelListPageQuery(
          querySelectorAll: '#bookList .box',
          titleQuery: FetcherQuery(attribue: 'text', selector: '.list-title'),
          pageUrlQuery: FetcherQuery(attribue: 'href', selector: '.list-title'),
          coverUrlQuery: FetcherQuery(attribue: 'src', selector: '.list-img'),
          // nextUrlQuery: NextUrlQuery(
          //   querySelectorAll: '.pagination a',
          //   hostUrl: 'https://lightnovelworld.org/genre-all',
          //   itemTextQuery: FetcherQuery(attribue: 'text', selector: ''),
          //   itemUrlQuery: FetcherQuery(attribue: 'href', selector: ''),
          // ),
        ),
        detailPageQuery: DetailPageQuery(
          title: FetcherQuery(
            attribue: HtmlAttribute.text.value,
            selector: '.book_info .tit h1',
          ),
          author: FetcherQuery(
            index: 2,
            attribue: HtmlAttribute.text.value,
            selector: '.list .item',
          ),
          coverUrl: FetcherQuery(
            attribue: HtmlAttribute.src.value,
            selector: '.book_cover',
          ),
          description: FetcherQuery(
            attribue: HtmlAttribute.text.value,
            selector: '.detail-desc',
          ),
          tags: FetcherQuery(
            attribue: HtmlAttribute.text.value,
            selector: '.genre-tags a',
            type: FetcherQueryType.list,
          ),
        ),
        chapterListPageQuery: ChapterListPageQuery(
          querySelectorAll: '.chapter-list-item',
          pageUrlQuery: FetcherQuery(attribue: 'href', selector: 'a'),
          titleQuery: FetcherQuery(
            attribue: HtmlAttribute.text.value,
            selector: 'a',
          ),
          numberQuery: FetcherQuery(
            attribue: HtmlAttribute.text.value,
            selector: 'a',
          ),
        ),
        chapterPageQuery: ChapterPageQuery(
          titleQuery: FetcherQuery(
            attribue: 'text',
            selector: '.book_title h1',
          ),
          contentQuery: FetcherQuery(
            attribue: 'html',
            selector: '#readcontent',
          ),
        ),
      ),
    ];
    return _websiteListCache;
  }
}
