import '../fetchers/web_chapter_list_fetcher.dart';
import '../querys/f_query.dart';
import '../types/website.dart';
import '../types/website_info.dart';

class WebsiteServices {
  static Future<List<WebSite>> getList() async {
    List<WebSite> list = [
      WebSite(
        title: 'mmxianxia',
        url: 'https://mmxianxia.com',
        info: WebsiteInfo(
          titleQuery: FQuery(selector: '.entry-title'),
          engTitleQuery: FQuery(selector: '.sertoinfo .alter'),
          coverUrlQuery: FQuery(selector: '.wp-post-image', attr: 'data-src'),
          // authorQuery: FQuery(selector: '.serval a'),
          // translatorQuery: FQuery(selector: ''),
          tagsQuery: FQuery(selector: '.sertogenre a', isMultiSelector: true),
          descriptionQuery: FQuery(
            selector: '.entry-content',
            isHtmlStyleText: true,
          ),
        ),
        webChapterList: WebChapterListFetcher(
          querySelectorAll: '.epl-title',
          titleQuery: FQuery(selector: ''),
          urlQuery: FQuery(selector: '', isParentElement: true, attr: 'href'),
          contentQuery: FQuery(
            selector: '.entry-content',
            isHtmlStyleText: true,
          ),
        ),
      ),
    ];
    return list;
  }
}
