import 'package:novel_v3/app/fetcher/fetcher_query.dart';
import 'package:novel_v3/app/fetcher/types/fetcher.dart';

class FetcherConfigServices {
  static Future<List<Fetcher>> getList() async {
    return [
      Fetcher(
        title: 'MM Xian Xia',
        url: 'https://mmxianxia.com',
        testUrl: 'https://mmxianxia.com/599718/',
        titleQuery: FetcherQuery(query: '.cat-series'),
        contentQuery: FetcherQuery(query: '.epcontent'),
      ),
      Fetcher(
        title: 'Telegra',
        url: 'https://telegra.ph/',
        testUrl:
            'https://telegra.ph/%E1%81%81%E1%81%81%E1%81%84%E1%81%87-04-29',
        titleQuery: FetcherQuery(query: ''),
        // titleQuery: FetcherQuery(query: '.tl_article_header h1'),
        contentQuery: FetcherQuery(query: '#_tl_editor'),
      ),
    ];
  }
}
