import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/types/chapter_list_page_query.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/types/fetch_website.dart';
import 'package:t_client/t_client.dart';
import 'package:t_html_parser/core/types/attributes.dart';

class WebsiteServices {
  static final WebsiteServices instance = WebsiteServices._();
  WebsiteServices._();
  factory WebsiteServices() => instance;
  final client = TClient();

  static List<FetcherWebsite> _websiteListCache = [];

  Future<List<FetcherWebsite>> getList({bool isLocal = false}) async {
    if (_websiteListCache.isNotEmpty && !isLocal) {
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
          autoAddUrlParam: '',
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
